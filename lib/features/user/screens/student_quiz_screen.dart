import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/quiz_model.dart';
import '../../admin/quiz_settings/question_cubit.dart';
import '../../../features/auth/cubit/auth_cubit.dart';

class StudentQuizScreen extends StatefulWidget {
  final QuizModel quiz;
  const StudentQuizScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  int _currentPageIndex = 0;
  Map<int, int> _selectedAnswers = {}; // {questionIndex: selectedOptionIndex}

  // টাইমার ভেরিয়েবল
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // ডাটাবেস থেকে এই কুইজের প্রশ্নগুলো লোড করা হচ্ছে
    context.read<QuestionCubit>().loadQuestions(widget.quiz.id);

    // টাইমার সেটআপ (মিনিট থেকে সেকেন্ডে রূপান্তর)
    _remainingSeconds = widget.quiz.totalTimerMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _autoSubmitQuiz(); // সময় শেষ হলে অটো সাবমিট
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ভুলে সাবমিট হওয়া ঠেকাতে কনফার্মেশন ডায়ালগ
  void _confirmSubmission() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('নিশ্চিত করুন', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('আপনি কি পরীক্ষা শেষ করে উত্তর জমা দিতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('না, চালিয়ে যাব', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _autoSubmitQuiz();
            },
            child: const Text('হ্যাঁ, জমা দিন'),
          ),
        ],
      ),
    );
  }

  void _autoSubmitQuiz() {
    // কুইজ সাবমিট করার পর রেজাল্ট ডায়ালগ দেখানো
    _showResultDialog();
  }

  void _showResultDialog() {
    _timer?.cancel();
    final questionsState = context.read<QuestionCubit>().state;
    if (questionsState is! QuestionLoaded) return;

    int totalQuestions = questionsState.questions.length;
    int correctAnswers = 0;
    int wrongAnswers = 0;

    _selectedAnswers.forEach((qIndex, optIndex) {
      if (questionsState.questions[qIndex].correctOptionIndex == optIndex) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }
    });

    // নেগেটিভ মার্কিং ক্যালকুলেশন
    double score = correctAnswers.toDouble();
    if (widget.quiz.hasNegativeMarking) {
      score -= (wrongAnswers * (widget.quiz.negativeMarkValue ?? 0.25));
    }

    // শূন্যের নিচে যেন স্কোর না যায়
    if (score < 0) score = 0;

    // পাস করেছে কি না চেক করা (শতকরা হিসেবে)
    double percentage = (score / totalQuestions) * 100;
    bool isPassed = percentage >= widget.quiz.passingMarks;

    // XP ক্যালকুলেশন
    int earnedXP = isPassed ? (correctAnswers * 10) : 0;

    // ডাটাবেসে XP যোগ করা
    if (earnedXP > 0) {
      context.read<AuthCubit>().addExperiencePoints(earnedXP);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Icon(
              isPassed
                  ? Icons.emoji_events_rounded
                  : Icons.sentiment_dissatisfied_rounded,
              color: isPassed ? Colors.amber : Colors.redAccent,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              isPassed
                  ? 'অভিনন্দন! তুমি পাস করেছো 🎉'
                  : 'দুঃখিত, তুমি পাস করতে পারোনি 😔',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'মোট প্রশ্ন: $totalQuestions',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'সঠিক উত্তর: $correctAnswers ✅',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'ভুল উত্তর: $wrongAnswers ❌',
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            const Divider(height: 24),
            Text(
              'প্রাপ্ত নম্বর: $score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            // XP অ্যানিমেশন বা টেক্সট
            if (earnedXP > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(color: Colors.amber.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                  ]
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '+$earnedXP XP অর্জিত!',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                backgroundColor: isPassed ? Colors.green : Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text(
                'ঠিক আছে',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.quiz.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // প্রিমিয়াম টাইমার ডিজাইন
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _remainingSeconds < 60
                  ? Colors.redAccent.withOpacity(0.15)
                  : theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _remainingSeconds < 60
                    ? Colors.redAccent
                    : theme.colorScheme.primary.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: _remainingSeconds < 60
                      ? Colors.redAccent
                      : theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimer(_remainingSeconds),
                  style: TextStyle(
                    color: _remainingSeconds < 60
                        ? Colors.redAccent
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<QuestionCubit, QuestionState>(
        builder: (context, state) {
          if (state is QuestionLoading)
            return const Center(child: CircularProgressIndicator());

          if (state is QuestionLoaded) {
            if (state.questions.isEmpty) {
              return const Center(
                child: Text('এই কুইজে কোনো প্রশ্ন পাওয়া যায়নি।'),
              );
            }

            final currentQuestion = state.questions[_currentPageIndex];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // অ্যানিমেটেড প্রোগ্রেস বার
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentPageIndex + 1) / state.questions.length,
                      minHeight: 8,
                      backgroundColor: theme.dividerColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // প্রশ্নের সংখ্যা নির্দেশক
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'প্রশ্ন ${_currentPageIndex + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'মোট: ${state.questions.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // মূল প্রশ্ন কার্ড
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
                      ]
                    ),
                    child: Text(
                      currentQuestion.questionText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // অপশনসমূহের লিস্ট (AnimatedContainer ব্যবহার করে প্রিমিয়াম ফিল)
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, optIndex) {
                        final isSelected = _selectedAnswers[_currentPageIndex] == optIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAnswers[_currentPageIndex] = optIndex;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1)
                                  : (isDark ? const Color(0xFF2A2A3A) : Colors.grey.shade50),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.dividerColor.withOpacity(0.1),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(color: theme.colorScheme.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                              ] : [],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.grey.withOpacity(0.2),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + optIndex), // A, B, C, D
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : theme.textTheme.bodyMedium?.color,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                currentQuestion.options[optIndex],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // নেভিগেশন বাটনসমূহ (Next / Previous / Submit)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPageIndex > 0)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => setState(() => _currentPageIndex--),
                            icon: const Icon(Icons.arrow_back_rounded, size: 20),
                            label: const Text('পেছনে', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        else
                          const SizedBox(),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: _currentPageIndex == state.questions.length - 1 ? Colors.green : theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            if (_currentPageIndex < state.questions.length - 1) {
                              setState(() => _currentPageIndex++);
                            } else {
                              _confirmSubmission(); // শেষ প্রশ্নে কনফার্মেশন দেখাবে
                            }
                          },
                          label: Text(
                            _currentPageIndex == state.questions.length - 1
                                ? 'পরীক্ষা শেষ করো'
                                : 'পরবর্তী',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          icon: Icon(
                            _currentPageIndex == state.questions.length - 1 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
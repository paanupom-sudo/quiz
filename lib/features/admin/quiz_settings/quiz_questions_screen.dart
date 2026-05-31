import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/quiz_model.dart';
import '../../../data/models/question_model.dart';
import 'question_cubit.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final QuizModel quiz;
  const QuizQuestionsScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuestionCubit>().loadQuestions(widget.quiz.id);
  }

  void _showAddQuestionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MCQBuilderDialog(quizId: widget.quiz.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.quiz.title, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // দীর্ঘ টাইটেল হলে ওভারফ্লো হবে না
            ),
            const Text('প্রশ্ন ম্যানেজমেন্ট', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddQuestionDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('নতুন প্রশ্ন', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: BlocBuilder<QuestionCubit, QuestionState>(
        builder: (context, state) {
          if (state is QuestionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is QuestionLoaded) {
            if (state.questions.isEmpty) {
              return Center(
                child: SingleChildScrollView( // ল্যান্ডস্কেপ মোডে ওভারফ্লো প্রতিরোধের জন্য
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.05),
                        ),
                        child: Icon(Icons.assignment_add, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 16),
                      Text('কোনো প্রশ্ন নেই', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'এই কুইজে নতুন MCQ যোগ করতে নিচের বাটনে ক্লিক করুন।', 
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: state.questions.length,
              itemBuilder: (context, index) {
                final q = state.questions[index];
                // ছোট স্ক্রিনের জন্য মার্জিন এডজাস্টমেন্ট
                final double responsiveLeftMargin = screenWidth > 400 ? 52 : 36;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16), // প্যাডিং কিছুটা কমানো হলো রেসপন্সিভনেসের জন্য
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}', 
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                q.questionText, 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.4)
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            constraints: const BoxConstraints(), // আইকনের বাড়তি জায়গা কমাবে
                            padding: EdgeInsets.zero,
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            ),
                            onPressed: () {
                              _confirmDelete(context, () => context.read<QuestionCubit>().deleteQuestion(q.id, widget.quiz.id));
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Options List
                      ...List.generate(q.options.length, (optIndex) {
                        final isCorrect = q.correctOptionIndex == optIndex;
                        return Container(
                          margin: EdgeInsets.only(bottom: 10, left: responsiveLeftMargin),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isCorrect ? Colors.green.withOpacity(0.1) : theme.scaffoldBackgroundColor,
                            border: Border.all(color: isCorrect ? Colors.green : theme.dividerColor.withOpacity(0.2), width: isCorrect ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle_rounded : Icons.circle_outlined, 
                                color: isCorrect ? Colors.green : Colors.grey.withOpacity(0.5), 
                                size: 18
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  q.options[optIndex], 
                                  style: TextStyle(
                                    fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                    color: isCorrect ? Colors.green.shade700 : null,
                                    fontSize: 14,
                                  )
                                )
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      if (q.explanation != null && q.explanation!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          margin: EdgeInsets.only(left: responsiveLeftMargin),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.1)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded, color: Colors.blue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  q.explanation!, 
                                  style: const TextStyle(fontSize: 13, color: Colors.blueGrey)
                                )
                              ),
                            ],
                          ),
                        )
                      ]
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('সতর্কতা!'),
          ],
        ),
        content: const Text('আপনি কি সত্যিই এই প্রশ্নটি ডিলিট করতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('ডিলিট করুন'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MCQ BUILDER DIALOG (Fully Responsive & Keyboard-Safe)
// ============================================================================
class _MCQBuilderDialog extends StatefulWidget {
  final String quizId;
  const _MCQBuilderDialog({Key? key, required this.quizId}) : super(key: key);

  @override
  State<_MCQBuilderDialog> createState() => _MCQBuilderDialogState();
}

class _MCQBuilderDialogState extends State<_MCQBuilderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctOptionIndex = 0;

  void _addOption() {
    if (_optionControllers.length < 6) {
      setState(() => _optionControllers.add(TextEditingController()));
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
        if (_correctOptionIndex >= _optionControllers.length) {
          _correctOptionIndex = _optionControllers.length - 1;
        }
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.post_add_rounded, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          const Text('নতুন MCQ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: ConstrainedBox(
        // এখানে Constraints ব্যবহারের ফলে এটি মোবাইল, ট্যাবলেট ও ডেস্কটপ সব ডিভাইসে পারফেক্ট সাইজ নিবে
        constraints: BoxConstraints(
          maxWidth: 600, 
          maxHeight: MediaQuery.of(context).size.height * 0.6, // কিবোর্ড আসলে ডায়ালগ সঙ্কুচিত হবে
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: _questionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'মূল প্রশ্ন লিখুন',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: theme.dividerColor.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (val) => val!.trim().isEmpty ? 'প্রশ্ন প্রদান করা আবশ্যক' : null,
                ),
                const SizedBox(height: 20),
                
                // রেস্পন্সিভ হেডার (স্ক্রিন ছোট হলে লেখা এবং বাটন নিচে নামবে না, সুন্দরভাবে ফিট হবে)
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'অপশনসমূহ (সঠিক উত্তরটি সিলেক্ট করুন)', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                      ),
                    ),
                    if (_optionControllers.length < 6)
                      TextButton.icon(
                        onPressed: _addOption,
                        icon: const Icon(Icons.add_circle_rounded, size: 18),
                        label: const Text('বাড়ান', style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          padding: EdgeInsets.zero,
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 10),

                // ডাইনামিক অপশন লিস্ট
                ...List.generate(_optionControllers.length, (index) {
                  final isCorrect = _correctOptionIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green.withOpacity(0.05) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isCorrect ? Colors.green.withOpacity(0.5) : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: _correctOptionIndex,
                            activeColor: Colors.green,
                            onChanged: (val) => setState(() => _correctOptionIndex = val!),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                hintText: 'অপশন ${String.fromCharCode(65 + index)}',
                                filled: true,
                                fillColor: theme.scaffoldBackgroundColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isCorrect ? Colors.green : theme.colorScheme.primary, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (val) => val!.trim().isEmpty ? 'খালি রাখা যাবে না' : null,
                            ),
                          ),
                          if (_optionControllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                              onPressed: () => _removeOption(index),
                            )
                          else
                            const SizedBox(width: 12), // ন্যূনতম স্পেসিং
                        ],
                      ),
                    ),
                  );
                }),

                const Divider(height: 24),
                TextFormField(
                  controller: _explanationController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'ব্যাখ্যা (ঐচ্ছিক)',
                    hintText: 'উত্তর সাবমিট করার পর স্টুডেন্ট এটি দেখতে পাবে...',
                    filled: true,
                    fillColor: theme.dividerColor.withOpacity(0.05),
                    prefixIcon: const Icon(Icons.lightbulb_outline_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('বাতিল', style: TextStyle(color: Colors.grey))
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final optionsList = _optionControllers.map((c) => c.text.trim()).toList();
              
              final question = QuestionModel(
                id: '',
                quizId: widget.quizId,
                questionText: _questionController.text.trim(),
                options: optionsList,
                correctOptionIndex: _correctOptionIndex,
                explanation: _explanationController.text.trim().isEmpty ? null : _explanationController.text.trim(),
              );
              
              context.read<QuestionCubit>().saveQuestion(question);
              Navigator.pop(context);
            }
          },
          child: const Text('সেভ করুন', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
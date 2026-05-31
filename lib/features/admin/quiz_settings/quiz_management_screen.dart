import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz/features/admin/quiz_settings/quiz_questions_screen.dart';

import '../../../data/models/class_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/quiz_model.dart';

import '../class_management/class_cubit.dart';
import '../class_management/subject_chapter_cubit.dart';
import 'quiz_cubit.dart';

// ============================================================================
// 1. QUIZ SETTINGS DIALOG (প্রিমিয়াম ডায়ালগ কম্পোনেন্ট)
// ============================================================================
class QuizSettingsDialog extends StatefulWidget {
  final String chapterId;
  const QuizSettingsDialog({Key? key, required this.chapterId})
    : super(key: key);

  @override
  State<QuizSettingsDialog> createState() => _QuizSettingsDialogState();
}

class _QuizSettingsDialogState extends State<QuizSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  bool _hasNegativeMarking = false;
  double _timerValue = 10;
  bool _antiCheat = false;
  bool _shuffleQuestions = true;
  double _passingMarks = 40;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings_suggest_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'কুইজ সেটিংস',
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'কুইজের নাম',
                    hintText: 'যেমন: Basic Math Quiz',
                    filled: true,
                    fillColor: theme.dividerColor.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.title_rounded),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'দয়া করে কুইজের নাম দিন' : null,
                ),
                const SizedBox(height: 24),

                // Timer Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'সময় নির্ধারণ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_timerValue.toInt()} মিনিট',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _timerValue,
                  min: 5,
                  max: 120,
                  divisions: 23,
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
                  label: _timerValue.round().toString(),
                  onChanged: (val) => setState(() => _timerValue = val),
                ),
                const SizedBox(height: 16),

                // Passing Marks Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'পাসিং মার্কস',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_passingMarks.toInt()}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _passingMarks,
                  min: 10,
                  max: 100,
                  divisions: 9,
                  activeColor: Colors.green,
                  inactiveColor: Colors.green.withOpacity(0.2),
                  label: _passingMarks.round().toString(),
                  onChanged: (val) => setState(() => _passingMarks = val),
                ),

                const Divider(height: 32),

                // Switches
                _buildModernSwitch(
                  theme,
                  title: 'প্রশ্ন শাফল (Shuffle)',
                  subtitle: 'প্রত্যেক স্টুডেন্ট আলাদা সিরিয়ালে প্রশ্ন পাবে',
                  value: _shuffleQuestions,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (val) => setState(() => _shuffleQuestions = val),
                ),
                const SizedBox(height: 12),
                _buildModernSwitch(
                  theme,
                  title: 'নেগেটিভ মার্কিং',
                  subtitle: 'ভুল উত্তরের জন্য ০.২৫ নম্বর কাটা হবে',
                  value: _hasNegativeMarking,
                  activeColor: Colors.orange,
                  onChanged: (val) => setState(() => _hasNegativeMarking = val),
                ),
                const SizedBox(height: 12),
                _buildModernSwitch(
                  theme,
                  title: 'অ্যান্টি-চিট মোড',
                  subtitle: 'ট্যাব পরিবর্তন করলে কুইজ অটো-সাবমিট হবে',
                  value: _antiCheat,
                  activeColor: Colors.redAccent,
                  onChanged: (val) => setState(() => _antiCheat = val),
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final quiz = QuizModel(
                id: '', // DB auto generates
                chapterId: widget.chapterId,
                title: _titleController.text.trim(),
                hasNegativeMarking: _hasNegativeMarking,
                totalTimerMinutes: _timerValue.toInt(),
                antiCheatMode: _antiCheat,
                shuffleQuestions: _shuffleQuestions,
                passingMarks: _passingMarks.toInt(),
              );
              context.read<QuizCubit>().saveQuiz(quiz);
              Navigator.pop(context);
            }
          },
          child: const Text(
            'কুইজ সেভ করুন',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSwitch(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? activeColor.withOpacity(0.05)
            : theme.dividerColor.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? activeColor.withOpacity(0.3)
              : theme.dividerColor.withOpacity(0.1),
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        activeColor: activeColor,
        onChanged: onChanged,
      ),
    );
  }
}

// ============================================================================
// 2. MAIN QUIZ MANAGEMENT SCREEN
// ============================================================================
class QuizManagementScreen extends StatefulWidget {
  const QuizManagementScreen({Key? key}) : super(key: key);

  @override
  State<QuizManagementScreen> createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends State<QuizManagementScreen> {
  String? _selectedClassId;
  String? _selectedSubjectId;
  String? _selectedChapterId;

  @override
  void initState() {
    super.initState();
    context.read<ClassCubit>().loadClasses();
  }

  // --- ডিলিট কনফার্মেশন ডায়ালগ ---
  void _confirmDeleteQuiz(BuildContext context, QuizModel quiz) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'সতর্কতা!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'আপনি কি সত্যিই "${quiz.title}" কুইজটি ডিলিট করতে চান? এর ভেতরের সব প্রশ্ন ডিলিট হয়ে যাবে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // TODO: context.read<QuizCubit>().deleteQuiz(quiz.id);
              Navigator.pop(ctx);
            },
            child: const Text('হ্যাঁ, ডিলিট করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _selectedChapterId != null
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      QuizSettingsDialog(chapterId: _selectedChapterId!),
                );
              },
              icon: const Icon(Icons.add_task_rounded),
              label: const Text(
                'নতুন কুইজ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            16.0,
          ), // Reduced default padding slightly for small screens
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'কুইজ ম্যানেজমেন্ট ⏱️',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'সিস্টেমের সমস্ত কুইজ এবং তার সেটিংস এখান থেকে কন্ট্রোল করুন।',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // ফিল্টার সেকশন (Responsive Class > Subject > Chapter)
              _buildFilters(theme),
              const SizedBox(height: 24),

              // কুইজ লিস্ট বা এম্পটি স্টেট
              Expanded(
                child: _selectedChapterId == null
                    ? _buildEmptyState(
                        theme,
                        'কুইজ দেখতে উপরের মেনু থেকে নির্দিষ্ট চ্যাপ্টার নির্বাচন করুন।',
                        Icons.touch_app_rounded,
                      )
                    : BlocBuilder<QuizCubit, QuizState>(
                        builder: (context, state) {
                          if (state is QuizLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is QuizLoaded) {
                            if (state.quizzes.isEmpty) {
                              return _buildEmptyState(
                                theme,
                                'এই চ্যাপ্টারে এখনো কোনো কুইজ নেই। নিচে থেকে "নতুন কুইজ" তৈরি করুন।',
                                Icons.quiz_outlined,
                              );
                            }

                            return GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 400,
                                    mainAxisExtent: 220, // Height of card
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: state.quizzes.length,
                              itemBuilder: (context, index) {
                                return _buildQuizCard(
                                  theme,
                                  state.quizzes[index],
                                );
                              },
                            );
                          }
                          return const SizedBox();
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ৩ টি ড্রপডাউন ফিল্টার (Responsive Layout) ---
  Widget _buildFilters(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // স্ক্রিন সাইজ ছোট হলে ড্রপডাউনগুলো নিচে নিচে বসবে (Column layout)
        if (constraints.maxWidth < 650) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildClassDropdown(theme),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
                _buildSubjectDropdown(theme),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
                _buildChapterDropdown(theme),
              ],
            ),
          );
        } else {
          // বড় স্ক্রিনে আগের মতো পাশাপাশি থাকবে (Row layout)
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: _buildClassDropdown(theme)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                ),
                Expanded(child: _buildSubjectDropdown(theme)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                ),
                Expanded(child: _buildChapterDropdown(theme)),
              ],
            ),
          );
        }
      },
    );
  }

  // --- এক্সট্র্যাক্ট করা ড্রপডাউন মেথডসমূহ ---
  Widget _buildClassDropdown(ThemeData theme) {
    return BlocBuilder<ClassCubit, ClassState>(
      builder: (context, state) {
        if (state is ClassLoaded) {
          return _buildModernDropdown(
            theme: theme,
            hint: 'ক্লাস সিলেক্ট করুন',
            icon: Icons.school_rounded,
            value: _selectedClassId,
            items: state.classes
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedClassId = val;
                _selectedSubjectId = null;
                _selectedChapterId = null;
              });
              context.read<SubjectChapterCubit>().loadSubjects(val!);
            },
          );
        }
        return const Center(child: LinearProgressIndicator());
      },
    );
  }

  Widget _buildSubjectDropdown(ThemeData theme) {
    return BlocBuilder<SubjectChapterCubit, SubjectChapterState>(
      builder: (context, state) {
        List<SubjectModel> subjects = [];
        if (state is SubChapLoaded) subjects = state.subjects;

        return _buildModernDropdown(
          theme: theme,
          hint: 'সাবজেক্ট সিলেক্ট করুন',
          icon: Icons.book_rounded,
          value: _selectedSubjectId,
          items: subjects
              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
              .toList(),
          onChanged: _selectedClassId == null
              ? null
              : (val) {
                  setState(() {
                    _selectedSubjectId = val;
                    _selectedChapterId = null;
                  });
                  context.read<SubjectChapterCubit>().loadChapters(val!);
                },
        );
      },
    );
  }

  Widget _buildChapterDropdown(ThemeData theme) {
    return BlocBuilder<SubjectChapterCubit, SubjectChapterState>(
      builder: (context, state) {
        List<ChapterModel> chapters = [];
        if (state is SubChapLoaded &&
            state.selectedSubjectId == _selectedSubjectId) {
          chapters = state.chapters;
        }

        return _buildModernDropdown(
          theme: theme,
          hint: 'চ্যাপ্টার সিলেক্ট করুন',
          icon: Icons.auto_stories_rounded,
          value: _selectedChapterId,
          items: chapters
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
              .toList(),
          onChanged: _selectedSubjectId == null
              ? null
              : (val) {
                  setState(() => _selectedChapterId = val);
                  context.read<QuizCubit>().loadQuizzes(val!);
                },
        );
      },
    );
  }

  Widget _buildModernDropdown({
    required ThemeData theme,
    required String hint,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          hint: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- কুইজ কার্ড UI ---
  Widget _buildQuizCard(ThemeData theme, QuizModel quiz) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizQuestionsScreen(quiz: quiz),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${quiz.totalTimerMinutes} মিনিট',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 18,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text('এডিট করুন'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_rounded,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'ডিলিট করুন',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') _confirmDeleteQuiz(context, quiz);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quiz.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (quiz.hasNegativeMarking)
                  _buildBadge(
                    Colors.orange,
                    'নেগেティブ',
                    Icons.remove_circle_outline,
                  ),
                if (quiz.antiCheatMode)
                  _buildBadge(
                    Colors.redAccent,
                    'অ্যান্টি-চিট',
                    Icons.security_rounded,
                  ),
                _buildBadge(
                  Colors.green,
                  'পাস: ${quiz.passingMarks}%',
                  Icons.check_circle_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Color color, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message, IconData icon) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.dividerColor.withOpacity(0.05),
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: theme.dividerColor.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

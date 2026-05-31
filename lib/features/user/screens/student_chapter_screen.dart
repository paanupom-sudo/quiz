import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../admin/class_management/subject_chapter_cubit.dart';
import '../../admin/quiz_settings/quiz_cubit.dart';
import 'student_quiz_screen.dart'; // আমরা পরের স্টেপে এই ফাইলটি বানাবো

class StudentChapterScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const StudentChapterScreen({
    Key? key,
    required this.subjectId,
    required this.subjectName,
  }) : super(key: key);

  @override
  State<StudentChapterScreen> createState() => _StudentChapterScreenState();
}

class _StudentChapterScreenState extends State<StudentChapterScreen> {
  @override
  void initState() {
    super.initState();
    // সাবজেক্টের চ্যাপ্টারগুলো লোড করা হচ্ছে
    context.read<SubjectChapterCubit>().loadChapters(widget.subjectId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<SubjectChapterCubit, SubjectChapterState>(
        builder: (context, state) {
          if (state is SubChapLoading) return const Center(child: CircularProgressIndicator());
          
          if (state is SubChapLoaded) {
            if (state.chapters.isEmpty) {
              return const Center(child: Text('এই সাবজেক্টে এখনও কোনো চ্যাপ্টার যোগ করা হয়নি।'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.chapters.length,
              itemBuilder: (context, index) {
                final chapter = state.chapters[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: Text('${index + 1}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(chapter.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('টাইপ: ${chapter.chapterType.toUpperCase()} • রিওয়ার্ড: ${chapter.xpReward} XP'),
                    onExpansionChanged: (expanded) {
                      if (expanded) {
                        // চ্যাপ্টারটি ওপেন করলে তার কুইজগুলো ফেচ হবে
                        context.read<QuizCubit>().loadQuizzes(chapter.id);
                      }
                    },
                    children: [
                      BlocBuilder<QuizCubit, QuizState>(
                        builder: (context, quizState) {
                          if (quizState is QuizLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (quizState is QuizLoaded) {
                            // শুধুমাত্র এই চ্যাপ্টারের কুইজগুলো ফিল্টার করে দেখাচ্ছি
                            final currentChapterQuizzes = quizState.quizzes.where((q) => q.chapterId == chapter.id).toList();

                            if (currentChapterQuizzes.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('এই চ্যাপ্টারে কোনো লাইভ কুইজ নেই।', style: TextStyle(color: Colors.grey)),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: currentChapterQuizzes.length,
                              itemBuilder: (context, qIndex) {
                                final quiz = currentChapterQuizzes[qIndex];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                  leading: const Icon(Icons.play_lesson_rounded, color: Colors.green),
                                  title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text('সময়: ${quiz.totalTimerMinutes} মিনিট • পাস: ${quiz.passingMarks}%'),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      // লাইভ কুইজ টেস্ট পেজে নিয়ে যাবে
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StudentQuizScreen(quiz: quiz),
                                        ),
                                      );
                                    },
                                    child: const Text('শুরু করো'),
                                  ),
                                );
                              },
                            );
                          }
                          return const SizedBox();
                        },
                      ),
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
}
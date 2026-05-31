import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/subject_model.dart';
import '../../admin/class_management/subject_chapter_cubit.dart';
import 'student_chapter_screen.dart';

class StudentSubjectScreen extends StatefulWidget {
  final String classId;
  final String className;

  const StudentSubjectScreen({
    Key? key,
    required this.classId,
    required this.className,
  }) : super(key: key);

  @override
  State<StudentSubjectScreen> createState() => _StudentSubjectScreenState();
}

class _StudentSubjectScreenState extends State<StudentSubjectScreen> {
  @override
  void initState() {
    super.initState();
    // স্ক্রিন লোড হওয়ার সাথে সাথে এই নির্দিষ্ট ক্লাসের সাবজেক্টগুলো ফেচ করা
    context.read<SubjectChapterCubit>().loadSubjects(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.className, 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<SubjectChapterCubit, SubjectChapterState>(
        builder: (context, state) {
          if (state is SubChapLoading) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          else if (state is SubChapLoaded) {
            if (state.subjects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'কোনো সাবজেক্ট নেই',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'এই ক্লাসে এখনো কোনো সাবজেক্ট যোগ করা হয়নি।',
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: state.subjects.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300, // রেসপন্সিভ গ্রিড
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final subject = state.subjects[index];
                // এখানে পুরো subject মডেলটি পাস করা হচ্ছে
                return _buildSubjectCard(context, subject);
              },
            );
          }
          
          return const Center(child: Text('সাবজেক্ট লোড করা হচ্ছে...'));
        },
      ),
    );
  }

  // সাবজেক্টের কার্ড ডিজাইন এবং নেভিগেশন
  Widget _buildSubjectCard(BuildContext context, SubjectModel subject) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        // সাবজেক্ট কার্ডে ক্লিক করলে চ্যাপ্টার স্ক্রিনে নিয়ে যাবে
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentChapterScreen(
              subjectId: subject.id,       // ডাটাবেস থেকে আসা সাবজেক্ট আইডি
              subjectName: subject.name,   // সাবজেক্টের নাম
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.secondary.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_stories_rounded, color: theme.colorScheme.secondary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              subject.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
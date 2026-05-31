import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/subject_model.dart';
import '../../../data/models/chapter_model.dart';
import 'class_cubit.dart';
import 'subject_chapter_cubit.dart';

class SubjectChapterScreen extends StatefulWidget {
  const SubjectChapterScreen({Key? key}) : super(key: key);

  @override
  State<SubjectChapterScreen> createState() => _SubjectChapterScreenState();
}

class _SubjectChapterScreenState extends State<SubjectChapterScreen> {
  String? _selectedClassId;
  SubjectModel? _selectedSubject;

  @override
  void initState() {
    super.initState();
    // স্ক্রিন লোড হলে প্রথমে ক্লাসের লিস্ট আনব
    context.read<ClassCubit>().loadClasses();
  }

  // --- ডিলিট কনফার্মেশন ডায়ালগ ---
  void _confirmDelete(
    BuildContext context,
    String title,
    VoidCallback onConfirm,
  ) {
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
            Flexible(
              child: Text(
                'নিশ্চিত করুন',
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'আপনি কি সত্যিই "$title" ডিলিট করতে চান? এই কাজ পরিবর্তনযোগ্য নয়।',
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
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('হ্যাঁ, ডিলিট করুন'),
          ),
        ],
      ),
    );
  }

  // --- সাবজেক্ট যোগ করার ডায়ালগ ---
  void _showAddSubjectDialog(BuildContext context) {
    if (_selectedClassId == null) return;

    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'নতুন সাবজেক্ট 📚',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Keyboard overflow এড়াতে SingleChildScrollView ব্যবহার করা হয়েছে
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'সাবজেক্টের নাম',
                hintText: 'যেমন: পদার্থবিজ্ঞান ১ম পত্র',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).dividerColor.withOpacity(0.05),
              ),
              validator: (val) => val!.isEmpty ? 'নাম প্রদান করা আবশ্যক' : null,
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newSubject = SubjectModel(
                  id: '',
                  classId: _selectedClassId!,
                  name: nameController.text.trim(),
                );
                context.read<SubjectChapterCubit>().addSubject(newSubject);
                Navigator.pop(ctx);
              }
            },
            child: const Text(
              'সেভ করুন',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- চ্যাপ্টার যোগ করার ডায়ালগ ---
  void _showAddChapterDialog(BuildContext context) {
    if (_selectedSubject == null) return;

    final nameController = TextEditingController();
    String selectedType = 'video';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          '${_selectedSubject!.name} - নতুন চ্যাপ্টার',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        // Keyboard overflow এড়াতে SingleChildScrollView
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'চ্যাপ্টারের নাম',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).dividerColor.withOpacity(0.05),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'নাম প্রদান করা আবশ্যক' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'ম্যাটেরিয়াল টাইপ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).dividerColor.withOpacity(0.05),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'video',
                      child: Row(
                        children: [
                          Icon(Icons.play_circle, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text('Video', overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('PDF Notes', overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'quiz',
                      child: Row(
                        children: [
                          Icon(Icons.quiz, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text('Quiz', overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'assignment',
                      child: Row(
                        children: [
                          Icon(Icons.assignment, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text('Assignment', overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) => selectedType = val!,
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newChapter = ChapterModel(
                  id: '',
                  subjectId: _selectedSubject!.id,
                  name: nameController.text.trim(),
                  chapterType: selectedType,
                  difficultyLevel: 'beginner',
                );
                context.read<SubjectChapterCubit>().addChapter(newChapter);
                Navigator.pop(ctx);
              }
            },
            child: const Text(
              'সেভ করুন',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    // স্ক্রিনের সাইজ অনুযায়ী ডাইনামিক প্যাডিং
    final double screenPadding = isDesktop ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'কারিকুলাম ম্যানেজমেন্ট 📚',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'এখান থেকে নির্দিষ্ট ক্লাসের সাবজেক্ট এবং চ্যাপ্টার পরিচালনা করুন।',
                style: TextStyle(color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isDesktop ? 24 : 16),

              // ১. Class Selector (Premium Dropdown)
              BlocBuilder<ClassCubit, ClassState>(
                builder: (context, state) {
                  if (state is ClassLoaded) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          hint: const Row(
                            children: [
                              Icon(Icons.school_rounded, color: Colors.grey),
                              SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'প্রথমে একটি ক্লাস নির্বাচন করুন...',
                                  style: TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          value: _selectedClassId,
                          items: state.classes.map((cls) {
                            return DropdownMenuItem(
                              value: cls.id,
                              child: Text(
                                cls.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClassId = value;
                              _selectedSubject = null; // ক্লাস চেঞ্জ করলে সাবজেক্ট ক্লিয়ার হবে
                            });
                            if (value != null) {
                              context.read<SubjectChapterCubit>().loadSubjects(value);
                            }
                          },
                        ),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 24),

              // ২. Split View (Subjects on Left, Chapters on Right)
              Expanded(
                child: _selectedClassId == null
                    ? Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_rounded,
                                size: 80,
                                color: theme.dividerColor.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'উপরের ড্রপডাউন থেকে একটি ক্লাস নির্বাচন করুন',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 1, child: _buildSubjectsList(theme, isDesktop)),
                              const SizedBox(width: 24),
                              Expanded(flex: 2, child: _buildChaptersList(theme, isDesktop)),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(child: _buildSubjectsList(theme, isDesktop)),
                              const SizedBox(height: 16),
                              Expanded(child: _buildChaptersList(theme, isDesktop)),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- বাম পাশের সাবজেক্ট লিস্ট ---
  Widget _buildSubjectsList(ThemeData theme, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
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
          Padding(
            padding: EdgeInsets.all(isDesktop ? 20.0 : 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'সাবজেক্টস',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    foregroundColor: theme.colorScheme.primary,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : 8, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('যুক্ত করুন'),
                  onPressed: () => _showAddSubjectDialog(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<SubjectChapterCubit, SubjectChapterState>(
              builder: (context, state) {
                if (state is SubChapLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SubChapLoaded) {
                  if (state.subjects.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'এই ক্লাসে এখনো কোনো সাবজেক্ট যোগ করা হয়নি।',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.subjects.length,
                    itemBuilder: (context, index) {
                      final subject = state.subjects[index];
                      final isSelected = _selectedSubject?.id == subject.id;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : theme.colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.book_rounded,
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            subject.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected ? Colors.white : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.redAccent,
                              size: 22,
                            ),
                            onPressed: () =>
                                _confirmDelete(context, subject.name, () {
                              context
                                  .read<SubjectChapterCubit>()
                                  .deleteSubject(subject.id);
                              if (isSelected) {
                                setState(() => _selectedSubject = null);
                              }
                            }),
                          ),
                          onTap: () {
                            setState(() => _selectedSubject = subject);
                            context
                                .read<SubjectChapterCubit>()
                                .loadChapters(subject.id);
                          },
                        ),
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
    );
  }

  // --- ডান পাশের চ্যাপ্টার লিস্ট ---
  Widget _buildChaptersList(ThemeData theme, bool isDesktop) {
    if (_selectedSubject == null) {
      return Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? Colors.white,
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 64,
                  color: theme.dividerColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'চ্যাপ্টার দেখতে বাম পাশ থেকে একটি সাবজেক্ট নির্বাচন করুন',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
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
          Padding(
            padding: EdgeInsets.all(isDesktop ? 20.0 : 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSubject!.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'সকল ম্যাটেরিয়াল ও চ্যাপ্টারসমূহ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 20 : 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showAddChapterDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    isDesktop ? 'নতুন যোগ করুন' : 'যোগ করুন',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<SubjectChapterCubit, SubjectChapterState>(
              builder: (context, state) {
                if (state is SubChapLoaded) {
                  if (state.selectedSubjectId != _selectedSubject!.id) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.chapters.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'এই সাবজেক্টে এখনো কোনো চ্যাপ্টার বা ম্যাটেরিয়াল নেই।',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = state.chapters[index];

                      // আইকন ও কালার নির্ধারণ
                      IconData getIcon() {
                        switch (chapter.chapterType) {
                          case 'video':
                            return Icons.play_circle_fill_rounded;
                          case 'pdf':
                            return Icons.picture_as_pdf_rounded;
                          case 'quiz':
                            return Icons.quiz_rounded;
                          case 'assignment':
                            return Icons.assignment_rounded;
                          default:
                            return Icons.article_rounded;
                        }
                      }

                      Color getColor() {
                        switch (chapter.chapterType) {
                          case 'video':
                            return Colors.blueAccent;
                          case 'pdf':
                            return Colors.redAccent;
                          case 'quiz':
                            return Colors.orange;
                          case 'assignment':
                            return Colors.green;
                          default:
                            return Colors.grey;
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: getColor().withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(getIcon(), color: getColor(), size: 24),
                          ),
                          title: Text(
                            chapter.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.dividerColor.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      chapter.chapterType.toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Colors.amber,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            '${chapter.xpReward ?? 0} XP',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.amber,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ডিলিট অ্যাকশন এবং কেটে যাওয়া কোড সম্পূর্ণ করা হয়েছে
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _confirmDelete(
                              context,
                              chapter.name,
                              () {
                                context
                                    .read<SubjectChapterCubit>()
                                    .deleteChapter(chapter.id);
                              },
                            ),
                          ),
                        ),
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
    );
  }
}
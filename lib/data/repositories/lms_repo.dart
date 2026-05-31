import 'package:quiz/data/models/question_model.dart';
import 'package:quiz/data/models/quiz_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/class_model.dart';
// নিচের দুটি ইমপোর্ট নতুন যোগ করা হয়েছে:
import '../models/subject_model.dart';
import '../models/chapter_model.dart';

class LMSRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  // ================= QUESTIONS CRUD =================
  Future<List<QuestionModel>> getQuestionsByQuiz(String quizId) async {
    final response = await _supabase
        .from('questions')
        .select()
        .eq('quiz_id', quizId)
        .order('created_at', ascending: true);
    return (response as List).map((e) => QuestionModel.fromJson(e)).toList();
  }

  Future<void> addQuestion(QuestionModel question) async {
    await _supabase.from('questions').insert(question.toJson());
  }

  Future<void> deleteQuestion(String id) async {
    await _supabase.from('questions').delete().eq('id', id);
  }

  // ================= QUIZ CRUD =================
  Future<List<QuizModel>> getQuizzesByChapter(String chapterId) async {
    final response = await _supabase
        .from('quizzes')
        .select()
        .eq('chapter_id', chapterId);
    return (response as List).map((e) => QuizModel.fromJson(e)).toList();
  }

  Future<void> addQuiz(QuizModel quiz) async {
    await _supabase.from('quizzes').insert(quiz.toJson());
  }

  Future<void> updateQuiz(String id, Map<String, dynamic> updates) async {
    await _supabase.from('quizzes').update(updates).eq('id', id);
  }
  // ================= CLASSES CRUD =================

  // 1. Get all classes
  Future<List<ClassModel>> getClasses() async {
    final response = await _supabase
        .from(AppConstants.classesTable)
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => ClassModel.fromJson(e)).toList();
  }

  // 2. Add a new class
  Future<void> addClass(ClassModel classModel) async {
    await _supabase.from(AppConstants.classesTable).insert(classModel.toJson());
  }

  // 3. Update an existing class
  Future<void> updateClass(String id, Map<String, dynamic> updates) async {
    await _supabase
        .from(AppConstants.classesTable)
        .update(updates)
        .eq('id', id);
  }

  // 4. Delete a class
  Future<void> deleteClass(String id) async {
    await _supabase.from(AppConstants.classesTable).delete().eq('id', id);
  }

  // ================= SUBJECTS CRUD =================

  Future<List<SubjectModel>> getSubjectsByClass(String classId) async {
    final response = await _supabase
        .from(AppConstants.subjectsTable)
        .select()
        .eq('class_id', classId)
        .order('sort_order', ascending: true);
    return (response as List).map((e) => SubjectModel.fromJson(e)).toList();
  }

  Future<void> addSubject(SubjectModel subject) async {
    await _supabase.from(AppConstants.subjectsTable).insert(subject.toJson());
  }

  Future<void> updateSubject(String id, Map<String, dynamic> updates) async {
    await _supabase
        .from(AppConstants.subjectsTable)
        .update(updates)
        .eq('id', id);
  }

  Future<void> deleteSubject(String id) async {
    await _supabase.from(AppConstants.subjectsTable).delete().eq('id', id);
  }

  // ================= CHAPTERS CRUD =================

  Future<List<ChapterModel>> getChaptersBySubject(String subjectId) async {
    final response = await _supabase
        .from(AppConstants.chaptersTable)
        .select()
        .eq('subject_id', subjectId)
        .order('sort_order', ascending: true);
    return (response as List).map((e) => ChapterModel.fromJson(e)).toList();
  }

  Future<void> addChapter(ChapterModel chapter) async {
    await _supabase.from(AppConstants.chaptersTable).insert(chapter.toJson());
  }

  Future<void> updateChapter(String id, Map<String, dynamic> updates) async {
    await _supabase
        .from(AppConstants.chaptersTable)
        .update(updates)
        .eq('id', id);
  }

  Future<void> deleteChapter(String id) async {
    await _supabase.from(AppConstants.chaptersTable).delete().eq('id', id);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/repositories/lms_repo.dart';

// --- States ---
abstract class SubjectChapterState {}

class SubChapInitial extends SubjectChapterState {}
class SubChapLoading extends SubjectChapterState {}
class SubChapLoaded extends SubjectChapterState {
  final List<SubjectModel> subjects;
  final List<ChapterModel> chapters;
  final String? selectedSubjectId;
  SubChapLoaded({required this.subjects, required this.chapters, this.selectedSubjectId});
}
class SubChapError extends SubjectChapterState {
  final String message;
  SubChapError(this.message);
}

// --- Cubit ---
class SubjectChapterCubit extends Cubit<SubjectChapterState> {
  final LMSRepository _lmsRepository;
  
  List<SubjectModel> _cachedSubjects = [];
  List<ChapterModel> _cachedChapters = [];
  String? _currentClassId;
  String? _currentSubjectId;

  SubjectChapterCubit(this._lmsRepository) : super(SubChapInitial());

  // ১. নির্দিষ্ট ক্লাসের সাবজেক্ট লোড করা
  Future<void> loadSubjects(String classId) async {
    _currentClassId = classId;
    _currentSubjectId = null;
    _cachedChapters = [];
    emit(SubChapLoading());
    try {
      _cachedSubjects = await _lmsRepository.getSubjectsByClass(classId);
      emit(SubChapLoaded(subjects: _cachedSubjects, chapters: _cachedChapters));
    } catch (e) {
      emit(SubChapError('সাবজেক্ট লোড করতে ব্যর্থ: $e'));
    }
  }

  // ২. নির্দিষ্ট সাবজেক্টের চ্যাপ্টার লোড করা
  Future<void> loadChapters(String subjectId) async {
    _currentSubjectId = subjectId;
    try {
      _cachedChapters = await _lmsRepository.getChaptersBySubject(subjectId);
      emit(SubChapLoaded(
        subjects: _cachedSubjects, 
        chapters: _cachedChapters, 
        selectedSubjectId: _currentSubjectId
      ));
    } catch (e) {
      emit(SubChapError('চ্যাপ্টার লোড করতে ব্যর্থ: $e'));
    }
  }

  // ৩. সাবজেক্ট অপারেশন
  Future<void> addSubject(SubjectModel subject) async {
    try {
      await _lmsRepository.addSubject(subject);
      if (_currentClassId != null) await loadSubjects(_currentClassId!);
    } catch (e) {
      emit(SubChapError('সাবজেক্ট যোগ করতে ব্যর্থ: $e'));
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _lmsRepository.deleteSubject(id);
      if (_currentClassId != null) await loadSubjects(_currentClassId!);
    } catch (e) {
      emit(SubChapError('সাবজেক্ট মুছতে ব্যর্থ: $e'));
    }
  }

  // ৪. চ্যাপ্টার অপারেশন
  Future<void> addChapter(ChapterModel chapter) async {
    try {
      await _lmsRepository.addChapter(chapter);
      if (_currentSubjectId != null) await loadChapters(_currentSubjectId!);
    } catch (e) {
      emit(SubChapError('চ্যাপ্টার যোগ করতে ব্যর্থ: $e'));
    }
  }

  Future<void> deleteChapter(String id) async {
    try {
      await _lmsRepository.deleteChapter(id);
      if (_currentSubjectId != null) await loadChapters(_currentSubjectId!);
    } catch (e) {
      emit(SubChapError('চ্যাপ্টার মুছতে ব্যর্থ: $e'));
    }
  }
}
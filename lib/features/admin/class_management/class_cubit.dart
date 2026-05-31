import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/class_model.dart';
import '../../../data/repositories/lms_repo.dart';

// --- States ---
abstract class ClassState {}

class ClassInitial extends ClassState {}
class ClassLoading extends ClassState {}
class ClassLoaded extends ClassState {
  final List<ClassModel> classes;
  ClassLoaded(this.classes);
}
class ClassError extends ClassState {
  final String message;
  ClassError(this.message);
}

// --- Cubit ---
class ClassCubit extends Cubit<ClassState> {
  final LMSRepository _lmsRepository;

  ClassCubit(this._lmsRepository) : super(ClassInitial());

  // Load classes from database
  Future<void> loadClasses() async {
    emit(ClassLoading());
    try {
      final classes = await _lmsRepository.getClasses();
      emit(ClassLoaded(classes));
    } catch (e) {
      emit(ClassError('ক্লাস লোড করতে সমস্যা হয়েছে: $e'));
    }
  }

  // Add new class
  Future<void> addClass(ClassModel classModel) async {
    try {
      await _lmsRepository.addClass(classModel);
      await loadClasses(); // Refresh list after adding
    } catch (e) {
      emit(ClassError('ক্লাস তৈরি করতে ব্যর্থ: $e'));
    }
  }

  // Update class
  Future<void> updateClass(String id, Map<String, dynamic> updates) async {
    try {
      await _lmsRepository.updateClass(id, updates);
      await loadClasses(); // Refresh list after updating
    } catch (e) {
      emit(ClassError('ক্লাস আপডেট করতে ব্যর্থ: $e'));
    }
  }

  // Delete class
  Future<void> deleteClass(String id) async {
    try {
      await _lmsRepository.deleteClass(id);
      await loadClasses(); // Refresh list after deleting
    } catch (e) {
      emit(ClassError('ক্লাস মুছতে ব্যর্থ: $e'));
    }
  }
}
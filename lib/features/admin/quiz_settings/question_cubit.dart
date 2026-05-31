import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/question_model.dart';
import '../../../data/repositories/lms_repo.dart';

abstract class QuestionState {}
class QuestionInitial extends QuestionState {}
class QuestionLoading extends QuestionState {}
class QuestionLoaded extends QuestionState {
  final List<QuestionModel> questions;
  QuestionLoaded(this.questions);
}
class QuestionError extends QuestionState {
  final String message;
  QuestionError(this.message);
}

class QuestionCubit extends Cubit<QuestionState> {
  final LMSRepository _lmsRepository;
  QuestionCubit(this._lmsRepository) : super(QuestionInitial());

  Future<void> loadQuestions(String quizId) async {
    emit(QuestionLoading());
    try {
      final questions = await _lmsRepository.getQuestionsByQuiz(quizId);
      emit(QuestionLoaded(questions));
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  }

  Future<void> saveQuestion(QuestionModel question) async {
    try {
      await _lmsRepository.addQuestion(question);
      await loadQuestions(question.quizId); // Refresh list
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  }

  Future<void> deleteQuestion(String id, String quizId) async {
    try {
      await _lmsRepository.deleteQuestion(id);
      await loadQuestions(quizId); // Refresh list
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  }
}
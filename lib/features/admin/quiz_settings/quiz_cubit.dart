import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repositories/lms_repo.dart';

abstract class QuizState {}
class QuizInitial extends QuizState {}
class QuizLoading extends QuizState {}
class QuizLoaded extends QuizState {
  final List<QuizModel> quizzes;
  QuizLoaded(this.quizzes);
}
class QuizError extends QuizState {
  final String message;
  QuizError(this.message);
}

class QuizCubit extends Cubit<QuizState> {
  final LMSRepository _lmsRepository;
  QuizCubit(this._lmsRepository) : super(QuizInitial());

  Future<void> loadQuizzes(String chapterId) async {
    emit(QuizLoading());
    try {
      final quizzes = await _lmsRepository.getQuizzesByChapter(chapterId);
      emit(QuizLoaded(quizzes));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> saveQuiz(QuizModel quiz) async {
    try {
      await _lmsRepository.addQuiz(quiz);
      loadQuizzes(quiz.chapterId);
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }
}
class QuestionModel {
  final String id;
  final String quizId;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      quizId: json['quiz_id'],
      questionText: json['question_text'],
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndex: json['correct_option_index'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'question_text': questionText,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'explanation': explanation,
    };
  }
}
class QuizModel {
  final String id;
  final String chapterId;
  final String title;
  final int totalMarks;
  final int passingMarks;
  final bool hasNegativeMarking;
  final double negativeMarkValue;
  final int totalTimerMinutes;
  final bool shuffleQuestions;
  final bool antiCheatMode;

  QuizModel({
    required this.id,
    required this.chapterId,
    required this.title,
    this.totalMarks = 100,
    this.passingMarks = 40,
    this.hasNegativeMarking = false,
    this.negativeMarkValue = 0.25,
    this.totalTimerMinutes = 10,
    this.shuffleQuestions = true,
    this.antiCheatMode = false,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'],
      chapterId: json['chapter_id'],
      title: json['title'],
      totalMarks: json['total_marks'] ?? 100,
      passingMarks: json['passing_marks'] ?? 40,
      hasNegativeMarking: json['has_negative_marking'] ?? false,
      negativeMarkValue: (json['negative_mark_value'] as num).toDouble(),
      totalTimerMinutes: json['total_timer_minutes'] ?? 10,
      shuffleQuestions: json['shuffle_questions'] ?? true,
      antiCheatMode: json['anti_cheat_mode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'title': title,
      'total_marks': totalMarks,
      'passing_marks': passingMarks,
      'has_negative_marking': hasNegativeMarking,
      'negative_mark_value': negativeMarkValue,
      'total_timer_minutes': totalTimerMinutes,
      'shuffle_questions': shuffleQuestions,
      'anti_cheat_mode': antiCheatMode,
    };
  }
}
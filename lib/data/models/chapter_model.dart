class ChapterModel {
  final String id;
  final String subjectId;
  final String name;
  final String? description;
  final String chapterType; // 'video', 'pdf', 'quiz', 'assignment', 'live'
  final String difficultyLevel; // 'beginner', 'intermediate', 'advanced'
  final int xpReward;
  final String status; // 'draft', 'published', 'scheduled', 'archived'
  final int sortOrder;

  ChapterModel({
    required this.id,
    required this.subjectId,
    required this.name,
    this.description,
    required this.chapterType,
    required this.difficultyLevel,
    this.xpReward = 10,
    this.status = 'draft',
    this.sortOrder = 0,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'],
      subjectId: json['subject_id'],
      name: json['name'],
      description: json['description'],
      chapterType: json['chapter_type'] ?? 'video',
      difficultyLevel: json['difficulty_level'] ?? 'beginner',
      xpReward: json['xp_reward'] ?? 10,
      status: json['status'] ?? 'draft',
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'name': name,
      'description': description,
      'chapter_type': chapterType,
      'difficulty_level': difficultyLevel,
      'xp_reward': xpReward,
      'status': status,
      'sort_order': sortOrder,
    };
  }
}
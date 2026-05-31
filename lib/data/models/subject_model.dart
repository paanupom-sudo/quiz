class SubjectModel {
  final String id;
  final String classId;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final String colorCode;
  final bool isPremium;
  final bool isPublished;
  final int sortOrder;

  SubjectModel({
    required this.id,
    required this.classId,
    required this.name,
    this.description,
    this.thumbnailUrl,
    this.colorCode = '#3B82F6',
    this.isPremium = false,
    this.isPublished = false,
    this.sortOrder = 0,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'],
      classId: json['class_id'],
      name: json['name'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      colorCode: json['color_code'] ?? '#3B82F6',
      isPremium: json['is_premium'] ?? false,
      isPublished: json['is_published'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'name': name,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'color_code': colorCode,
      'is_premium': isPremium,
      'is_published': isPublished,
      'sort_order': sortOrder,
    };
  }
}
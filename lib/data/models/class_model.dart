class ClassModel {
  final String id;
  final String name;
  final String? classCode;
  final String? academicYear;
  final String? medium;
  final bool isActive;

  ClassModel({
    required this.id,
    required this.name,
    this.classCode,
    this.academicYear,
    this.medium,
    required this.isActive,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      name: json['name'],
      classCode: json['class_code'],
      academicYear: json['academic_year'],
      medium: json['medium'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'class_code': classCode,
      'academic_year': academicYear,
      'medium': medium,
      'is_active': isActive,
    };
  }
}
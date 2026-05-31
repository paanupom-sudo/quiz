class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? selectedClassId;
  
  // নতুন গ্যামিফিকেশন ফিল্ডস
  final int xp;
  final int streak;
  final DateTime? lastActiveDate;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.selectedClassId,
    this.xp = 0,
    this.streak = 0,
    this.lastActiveDate,
  });

  bool get isAdmin => role == 'admin' || role == 'super_admin';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      selectedClassId: json['selected_class_id'],
      xp: json['xp'] ?? 0,
      streak: json['streak'] ?? 0,
      lastActiveDate: json['last_active_date'] != null 
          ? DateTime.parse(json['last_active_date']) 
          : null,
    );
  }
}
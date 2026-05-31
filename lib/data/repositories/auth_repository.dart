import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/profile_model.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ================= GAMIFICATION LOGIC =================

  Future<void> checkAndUpdateDailyStreak() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // ইউজারের বর্তমান প্রোফাইল ফেচ করা
      final currentProfile = await getCurrentProfile();
      if (currentProfile == null) return;

      final now = DateTime.now();
      final today = DateTime(
        now.year,
        now.month,
        now.day,
      ); // শুধুমাত্র তারিখ (সময় ছাড়া)

      int newStreak = currentProfile.streak;

      if (currentProfile.lastActiveDate == null) {
        // যদি জীবনে প্রথমবার অ্যাপে ঢুকে থাকে
        newStreak = 1;
      } else {
        final lastActive = DateTime(
          currentProfile.lastActiveDate!.year,
          currentProfile.lastActiveDate!.month,
          currentProfile.lastActiveDate!.day,
        );

        final difference = today.difference(lastActive).inDays;

        if (difference == 1) {
          // গতকাল ঢুকেছিল, তাই আজ Streak ১ বাড়বে
          newStreak += 1;
        } else if (difference > 1) {
          // মাঝখানে গ্যাপ দিয়েছে, তাই Streak আবার ১ থেকে শুরু হবে
          newStreak = 1;
        } else if (difference == 0) {
          // আজ আগেই ঢুকেছে, তাই Streak আপডেট করার দরকার নেই
          return;
        }
      }

      // ডাটাবেসে নতুন Streak এবং আজকের তারিখ আপডেট করা
      await _supabase
          .from(AppConstants.profilesTable)
          .update({
            'streak': newStreak,
            'last_active_date': today.toIso8601String().split('T')[0], // শুধু YYYY-MM-DD ফরম্যাট
          })
          .eq('id', user.id);
    } catch (e) {
      print("Streak Update Error: $e");
    }
  }

  // কুইজ শেষ করার পর XP যোগ করার ফাংশন (উইথ ট্র্যাকিং)
  Future<void> addXP(int xpToAdd) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print("🛑 XP Error: ইউজার লগইন করা নেই!");
        return;
      }

      final currentProfile = await getCurrentProfile();
      if (currentProfile != null) {
        final newXp = currentProfile.xp + xpToAdd;
        print("⏳ ডাটাবেসে XP আপডেট রিকোয়েস্ট পাঠানো হচ্ছে... (New XP: $newXp)");

        // .select() ব্যবহার করা হয়েছে যাতে আপডেট হওয়ার পর ডাটাবেস কি রেসপন্স দেয় তা দেখা যায়
        final response = await _supabase
            .from(AppConstants.profilesTable)
            .update({'xp': newXp})
            .eq('id', user.id)
            .select();

        print("✅ Supabase রেসপন্স: $response");
      } else {
        print("🛑 XP Error: বর্তমান প্রোফাইল ফেচ করা যায়নি!");
      }
    } catch (e) {
      print("🛑 XP Update Error: $e");
    }
  }

  // 1. Sign In
  Future<ProfileModel?> signIn(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return await getCurrentProfile();
      }
      return null;
    } catch (e) {
      throw Exception('লগইন ব্যর্থ হয়েছে: $e');
    }
  }

  // 2. Sign Up (Registration)
  Future<ProfileModel?> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // নতুন ইউজারের ডেটা profiles টেবিলে সেভ করা
        await _supabase.from(AppConstants.profilesTable).insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'role': 'student', // <-- নতুন ইউজার ডিফল্টভাবে স্টুডেন্ট হবে
        });

        return await getCurrentProfile();
      }
      return null;
    } catch (e) {
      throw Exception('রেজিস্ট্রেশন ব্যর্থ হয়েছে: $e');
    }
  }

  // 3. Get Current User Profile (Role checking)
  Future<ProfileModel?> getCurrentProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', user.id)
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('প্রোফাইল লোড করতে সমস্যা হয়েছে: $e');
    }
  }

  // 4. Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // 5. Update Selected Class
  Future<void> updateSelectedClass(String classId) async {
    final user = _supabase.auth.currentUser;
    await _supabase
        .from(AppConstants.profilesTable)
        .update({'selected_class_id': classId})
        .eq('id', user!.id);
  }
}
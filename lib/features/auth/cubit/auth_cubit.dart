import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/repositories/auth_repository.dart';

// --- States ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final ProfileModel profile;
  Authenticated(this.profile);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- Cubit ---
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());
  // 1. Check Initial Status (আপডেট করা হলো)
  Future<void> checkAuthStatus() async {
    try {
      final profile = await _authRepository.getCurrentProfile();
      if (profile != null) {
        // লগইন থাকার কারণে অ্যাপ ওপেন করলেই Streak চেক হবে
        await _authRepository.checkAndUpdateDailyStreak();

        // আপডেটেড প্রোফাইল আবার ফেচ করা হচ্ছে
        final updatedProfile = await _authRepository.getCurrentProfile();
        emit(Authenticated(updatedProfile!));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  // 2. Login
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final profile = await _authRepository.signIn(email, password);
      if (profile != null) {
        emit(Authenticated(profile));
      } else {
        emit(
          AuthError('লগইন ব্যর্থ হয়েছে। ইমেইল বা পাসওয়ার্ড ভুল হতে পারে।'),
        );
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // 3. Register (নতুন যোগ করা হলো)
  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final profile = await _authRepository.signUp(name, email, password);
      if (profile != null) {
        emit(
          Authenticated(profile),
        ); // রেজিস্ট্রেশন সফল হলে অটোমেটিক লগইন হয়ে যাবে
      } else {
        emit(AuthError('অ্যাকাউন্ট তৈরি করতে সমস্যা হয়েছে।'));
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // 4. Logout
  Future<void> logout() async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(Unauthenticated());
  }

  Future<void> updateProfileClass(String classId) async {
    emit(AuthLoading());
    try {
      await _authRepository.updateSelectedClass(classId);
      final profile = await _authRepository.getCurrentProfile();
      emit(Authenticated(profile!)); // আপডেট প্রোফাইল দিয়ে রি-এমিট করা
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // 5. XP যোগ করার মেথড (নতুন)
  Future<void> addExperiencePoints(int earnedXP) async {
    if (state is Authenticated) {
      final currentState = state as Authenticated;
      try {
        // ডাটাবেসে XP যোগ করা হচ্ছে
        await _authRepository.addXP(earnedXP);

        // অ্যাপের ভেতরে সাথে সাথে (Instant) UI আপডেট করার জন্য State আপডেট করা হচ্ছে
        final currentProfile = currentState.profile;
        final updatedProfile = ProfileModel(
          id: currentProfile.id,
          name: currentProfile.name,
          email: currentProfile.email,
          role: currentProfile.role,
          selectedClassId: currentProfile.selectedClassId,
          xp: currentProfile.xp + earnedXP, // নতুন XP যোগ হলো
          streak: currentProfile.streak,
          lastActiveDate: currentProfile.lastActiveDate,
        );

        emit(Authenticated(updatedProfile));
      } catch (e) {
        print("Cubit XP Update Error: $e");
      }
    }
  }
}

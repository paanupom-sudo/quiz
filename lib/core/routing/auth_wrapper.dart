import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/admin/layout/admin_layout.dart';
import '../../features/user/screens/student_main_layout.dart'; // <-- নতুন Layout ইমপোর্ট করা হলো

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is Authenticated) {
          // অ্যাডমিন চেক
          if (state.profile.isAdmin) {
            return const AdminLayout();
          } 
          // স্টুডেন্টের যদি ক্লাস সিলেক্ট করা না থাকে
          else if (state.profile.selectedClassId == null) {
            return const ProfileSetupScreen();
          } 
          // সবকিছু ঠিক থাকলে মেইন লেআউটে (Bottom Nav Bar সহ) পাঠাবে
          else {
            return const StudentMainLayout(); // <-- আপডেট করা হয়েছে
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
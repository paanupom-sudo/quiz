import 'package:flutter/material.dart';
import 'package:quiz/features/admin/quiz_settings/question_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/auth_wrapper.dart';

// Auth imports
import 'data/repositories/auth_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';

// LMS & Class Management imports (নতুন যোগ করা হয়েছে)
import 'data/repositories/lms_repo.dart';
import 'features/admin/class_management/class_cubit.dart';
import 'features/admin/class_management/subject_chapter_cubit.dart';
import 'features/admin/quiz_settings/quiz_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const LMSAdminApp());
}

class LMSAdminApp extends StatelessWidget {
  const LMSAdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Auth Repository Provide করা হলো
        RepositoryProvider(create: (context) => AuthRepository()),

        // LMS Repository Provide করা হলো (নতুন)
        RepositoryProvider(create: (context) => LMSRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          // AuthCubit Provide করা হলো এবং অ্যাপ চালুর সাথেই Status Check করা হচ্ছে
          BlocProvider(
            create: (context) =>
                AuthCubit(context.read<AuthRepository>())..checkAuthStatus(),
          ),

          // ClassCubit Provide করা হলো (নতুন)
          BlocProvider(
            create: (context) => ClassCubit(context.read<LMSRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                SubjectChapterCubit(context.read<LMSRepository>()),
          ),
          BlocProvider(
            create: (context) => QuizCubit(context.read<LMSRepository>()),
          ),
          BlocProvider(create: (context) => QuestionCubit(context.read<LMSRepository>())),
        ],
        child: MaterialApp(
          title: 'LMS Admin Dashboard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, // Auto switch based on device settings
          // ডামি স্ক্রিনের বদলে AuthWrapper বসানো হলো
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

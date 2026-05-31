import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Carousel Slider Import

import '../../../data/models/subject_model.dart';
import '../../admin/class_management/subject_chapter_cubit.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'student_chapter_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({Key? key}) : super(key: key);

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String? _myClassId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      _myClassId = authState.profile.selectedClassId;
      if (_myClassId != null) {
        context.read<SubjectChapterCubit>().loadSubjects(_myClassId!);
      }
    }
  }

  Future<void> _refreshData() async {
    if (_myClassId != null) {
      await context.read<SubjectChapterCubit>().loadSubjects(_myClassId!);
    }
  }

  // ডাইনামিক গ্রিটিং লজিক
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'শুভ সকাল 🌤';
    if (hour < 17) return 'শুভ দুপুর ☀️';
    if (hour < 20) return 'শুভ সন্ধ্যা 🌇';
    return 'শুভ রাত্রি 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background লেআউট থেকে আসবে
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar: Greeting & Gamification Stats
              _buildTopBar(theme, isDark),
              const SizedBox(height: 24),

              // 2. Smart Search Bar (Voice & Filter)
              _buildSmartSearchBar(theme, isDark),
              const SizedBox(height: 28),
              
              // 3. --- ব্যানার স্লাইডার ---
              _buildBannerCarousel(theme),
              const SizedBox(height: 28),

              // 4. Continue Learning Glass Card
              _buildContinueLearningCard(theme, isDark),
              const SizedBox(height: 28),

              // 5. Quick Actions
              Text(
                'কুইক অ্যাকশনস ⚡',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(theme),
              const SizedBox(height: 32),

              // 6. My Subjects Grid
              Text(
                'আমার সাবজেক্টসমূহ 📚',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSubjectsGrid(),
            ],
          ),
        ),
      ),

      // Floating AI Assistant
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: AI Chat Screen
        },
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildTopBar(ThemeData theme, bool isDark) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String userName = "স্টুডেন্ট";
        int streakCount = 0; // ডাইনামিক Streak
        int xpCount = 0; // ডাইনামিক XP

        // যদি ইউজার লগইন করা থাকে, তবে তার আসল ডেটাগুলো ভেরিয়েবলে নিচ্ছি
        if (state is Authenticated) {
          userName = state.profile.name;
          streakCount = state.profile.streak;
          xpCount = state.profile.xp;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Gamification Badge (Real-time data)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  // Streak Icon & Count
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    streakCount.toString(), // আসল Streak দেখানো হচ্ছে
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(width: 12),

                  // XP Icon & Count
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    xpCount.toString(), // আসল XP দেখানো হচ্ছে
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmartSearchBar(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'কী শিখতে চাও আজ?',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.mic_none_rounded,
                  color: Colors.blueAccent,
                ),
                onPressed: () {},
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.grey.withOpacity(0.3),
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: Colors.grey),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // --- নতুন যুক্ত করা ব্যানার স্লাইডার ---
  Widget _buildBannerCarousel(ThemeData theme) {
    final List<Map<String, dynamic>> banners = [
      {
        'title': 'আসন্ন পরীক্ষা 🚨',
        'subtitle': 'আগামীকাল ফিজিক্স মেগা কুইজ! প্রস্তুতি নাও এখনই।',
        'color': Colors.blueAccent,
        'icon': Icons.timer_rounded,
      },
      {
        'title': 'নতুন কোর্স 🔥',
        'subtitle': 'ইংলিশ গ্রামার প্রো কোর্স এখন লাইভ।',
        'color': Colors.purpleAccent,
        'icon': Icons.new_releases_rounded,
      },
      {
        'title': 'নোটিশ 📢',
        'subtitle': 'আগামী শুক্রবার মেইনটেন্যান্স এর জন্য অ্যাপ বন্ধ থাকবে।',
        'color': Colors.orangeAccent,
        'icon': Icons.campaign_rounded,
      }
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 140.0,
        autoPlay: true, 
        enlargeCenterPage: true, 
        viewportFraction: 1.0, 
        autoPlayInterval: const Duration(seconds: 4), 
      ),
      items: banners.map((banner) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (banner['color'] as Color).withOpacity(0.8),
                    (banner['color'] as Color),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (banner['color'] as Color).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner['title'],
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          banner['subtitle'],
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    banner['icon'], 
                    color: Colors.white.withOpacity(0.4), 
                    size: 64,
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildContinueLearningCard(ThemeData theme, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.secondary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'তুমি শেষ পড়েছিলে',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '65% Completed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'উচ্চতর গণিত',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'অধ্যায় ৫: সমীকরণ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.65,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      {
        'icon': Icons.description_rounded,
        'label': 'Notes',
        'color': Colors.blue,
      },
      {
        'icon': Icons.play_circle_fill_rounded,
        'label': 'Live',
        'color': Colors.redAccent,
      },
      {'icon': Icons.quiz_rounded, 'label': 'Quiz', 'color': Colors.orange},
      {
        'icon': Icons.download_rounded,
        'label': 'Offline',
        'color': Colors.green,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (action['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action['icon'] as IconData,
                color: action['color'] as Color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action['label'] as String,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSubjectsGrid() {
    return BlocBuilder<SubjectChapterCubit, SubjectChapterState>(
      builder: (context, state) {
        if (state is SubChapLoading)
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );

        if (state is SubChapLoaded) {
          if (state.subjects.isEmpty)
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('কোনো সাবজেক্ট নেই।'),
              ),
            );

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.subjects.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final subject = state.subjects[index];
              return _buildSubjectCard(context, subject);
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSubjectCard(BuildContext context, SubjectModel subject) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentChapterScreen(
              subjectId: subject.id,
              subjectName: subject.name,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.secondary.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
              child: Icon(
                Icons.auto_stories_rounded,
                color: theme.colorScheme.secondary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subject.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
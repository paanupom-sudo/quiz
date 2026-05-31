import 'package:flutter/material.dart';
import 'package:quiz/features/user/screens/student_leaderboard_screen.dart';
import 'package:quiz/features/user/screens/student_learn_screen.dart';
import 'student_home_screen.dart';
import 'student_profile_screen.dart';

class StudentMainLayout extends StatefulWidget {
  const StudentMainLayout({Key? key}) : super(key: key);

  @override
  State<StudentMainLayout> createState() => _StudentMainLayoutState();
}

class _StudentMainLayoutState extends State<StudentMainLayout> {
  int _currentIndex = 0;

  // অ্যাপের প্রধান স্ক্রিনগুলোর লিস্ট
  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const StudentLearnScreen(), // <-- এখানে লার্ন স্ক্রিন বসানো হলো
    const StudentLeaderboardScreen(), // <-- এখানে আপডেট করা হলো
    const StudentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: theme.colorScheme.primary.withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
            }
            return const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          elevation: 10,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: theme.colorScheme.primary,
              ),
              label: 'হোম',
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(
                Icons.menu_book_rounded,
                color: theme.colorScheme.primary,
              ),
              label: 'লার্ন',
            ),
            NavigationDestination(
              icon: const Icon(Icons.leaderboard_outlined),
              selectedIcon: Icon(
                Icons.leaderboard_rounded,
                color: theme.colorScheme.primary,
              ),
              label: 'লিডারবোর্ড',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: theme.colorScheme.primary,
              ),
              label: 'প্রোফাইল',
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Screens
import '../../auth/cubit/auth_cubit.dart';
import '../dashboard/admin_dashboard_screen.dart';
import '../class_management/class_screen.dart';
import '../class_management/subject_chapter_screen.dart';
import '../quiz_settings/quiz_management_screen.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({Key? key}) : super(key: key);

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  // নেভিগেশন মেনুর আইটেমগুলো
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard_rounded, 'title': 'ড্যাশবোর্ড'},
    {'icon': Icons.class_rounded, 'title': 'ক্লাস ম্যানেজমেন্ট'},
    {'icon': Icons.menu_book_rounded, 'title': 'সাবজেক্ট ও চ্যাপ্টার'},
    {'icon': Icons.quiz_rounded, 'title': 'কুইজ সেটিংস'},
    {'icon': Icons.people_alt_rounded, 'title': 'স্টুডেন্ট ম্যানেজমেন্ট'},
    {'icon': Icons.notifications_active_rounded, 'title': 'নোটিফিকেশন'},
  ];

  // Lazy Loading Method: যখন যে ইনডেক্স সিলেক্ট হবে, শুধু সেই স্ক্রিনটি রিটার্ন করবে
  Widget _buildSelectedScreen(int index) {
    switch (index) {
      case 0:
        return const AdminDashboardScreen();
      case 1:
        return const ClassScreen();
      case 2:
        return const SubjectChapterScreen();
      case 3:
        return const QuizManagementScreen();
      case 4:
        return _buildPlaceholderScreen('স্টুডেন্ট ম্যানেজমেন্ট 👨‍🎓');
      case 5:
        return _buildPlaceholderScreen('নোটিফিকেশন সিস্টেম 🔔');
      default:
        return const AdminDashboardScreen();
    }
  }

  Widget _buildPlaceholderScreen(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: isDesktop
          ? null // ডেস্কটপে অ্যাপবার দরকার নেই, সাইডবার থাকবে
          : AppBar(
              title: const Text('LMS Admin'),
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
            ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(theme, isDark)),
      body: Row(
        children: [
          // ডেস্কটপ মোডে ফিক্সড সাইডবার
          if (isDesktop) SizedBox(width: 260, child: _buildSidebar(theme, isDark)),

          // মূল কন্টেন্ট এরিয়া
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12121A) : const Color(0xFFF3F4F6),
                borderRadius: isDesktop
                    ? const BorderRadius.only(topLeft: Radius.circular(24))
                    : BorderRadius.zero,
              ),
              child: ClipRRect(
                borderRadius: isDesktop
                    ? const BorderRadius.only(topLeft: Radius.circular(24))
                    : BorderRadius.zero,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  // এখানে মেথডটি কল করা হচ্ছে
                  child: _buildSelectedScreen(_selectedIndex),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // সাইডবার উইজেট (ডেস্কটপ এবং ড্রয়ার উভয়ের জন্য)
  Widget _buildSidebar(ThemeData theme, bool isDark) {
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Logo & Branding
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'LMS Admin',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navigation Menu
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    key: ValueKey('menu_$index'),
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      if (!MediaQuery.of(context).size.width.isFinite ||
                          MediaQuery.of(context).size.width < 850) {
                        Navigator.pop(context); // মোবাইল মোডে ড্রয়ার বন্ধ করবে
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                    leading: Icon(
                      _menuItems[index]['icon'],
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.iconTheme.color?.withOpacity(0.6),
                    ),
                    title: Text(
                      _menuItems[index]['title'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Profile & Logout Area
          Divider(color: theme.dividerColor.withOpacity(0.1), height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                ),
              ),
              title: const Text(
                'লগআউট',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Logout Logic
                context.read<AuthCubit>().logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
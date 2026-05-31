import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('আমার প্রোফাইল', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              // TODO: Edit Profile Screen
            },
          )
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final profile = state.profile;
            
            // ইউজারের নামের প্রথম অক্ষর আইকনের জন্য
            final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'S';

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // 1. Header Section (Avatar & Info)
                  _buildProfileHeader(theme, profile.name, profile.email, initial),
                  const SizedBox(height: 24),

                  // 2. Gamification Stats (XP & Streak)
                  _buildGamificationStats(theme, isDark, profile.xp, profile.streak),
                  const SizedBox(height: 32),

                  // 3. Learning Activity Section
                  _buildSectionTitle(theme, 'লার্নিং অ্যাক্টিভিটি'),
                  _buildMenuCard(
                    theme,
                    isDark,
                    children: [
                      _buildMenuItem(context, Icons.history_rounded, Colors.purple, 'আমার কুইজ হিস্ট্রি', onTap: () {}),
                      _buildDivider(theme),
                      _buildMenuItem(context, Icons.bookmark_rounded, Colors.orange, 'সেভ করা নোটস', onTap: () {}),
                      _buildDivider(theme),
                      _buildMenuItem(context, Icons.bar_chart_rounded, Colors.blue, 'পারফরম্যান্স অ্যানালিটিক্স', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Account Settings Section
                  _buildSectionTitle(theme, 'অ্যাকাউন্ট সেটিংস'),
                  _buildMenuCard(
                    theme,
                    isDark,
                    children: [
                      _buildMenuItem(context, Icons.school_rounded, Colors.indigo, 'ক্লাস পরিবর্তন করুন', onTap: () {}),
                      _buildDivider(theme),
                      _buildMenuItem(context, Icons.lock_rounded, Colors.teal, 'পাসওয়ার্ড পরিবর্তন', onTap: () {}),
                      _buildDivider(theme),
                      _buildMenuItem(context, Icons.notifications_rounded, Colors.pink, 'নোটিফিকেশন', trailing: Switch(value: true, onChanged: (v){}), onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. Help & Logout Section
                  _buildSectionTitle(theme, 'অন্যান্য'),
                  _buildMenuCard(
                    theme,
                    isDark,
                    children: [
                      _buildMenuItem(context, Icons.help_outline_rounded, Colors.green, 'হেল্প সেন্টার', onTap: () {}),
                      _buildDivider(theme),
                      _buildMenuItem(context, Icons.privacy_tip_rounded, Colors.grey, 'প্রাইভেসি পলিসি', onTap: () {}),
                      _buildDivider(theme),
                      _buildMenuItem(
                        context, 
                        Icons.logout_rounded, 
                        Colors.redAccent, 
                        'লগআউট', 
                        textColor: Colors.redAccent,
                        showArrow: false,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // --- UI Components ---

  Widget _buildProfileHeader(ThemeData theme, String name, String email, String initial) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text(name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(email, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('প্রো স্টুডেন্ট', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        )
      ],
    );
  }

  Widget _buildGamificationStats(ThemeData theme, bool isDark, int xp, int streak) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(theme, isDark, 'অর্জিত XP', xp.toString(), Icons.star_rounded, Colors.amber)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(theme, isDark, 'ডেইলি স্ট্রিক', '$streak দিন', Icons.local_fire_department_rounded, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, bool isDark, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
      ),
    );
  }

  Widget _buildMenuCard(ThemeData theme, bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, Color iconColor, String title, {Widget? trailing, Color? textColor, bool showArrow = true, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
      trailing: trailing ?? (showArrow ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey) : null),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(height: 1, indent: 64, color: theme.dividerColor.withOpacity(0.1));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('লগআউট', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('আপনি কি নিশ্চিত যে আপনি অ্যাকাউন্ট থেকে লগআউট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('না', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout(); // AuthCubit থেকে লগআউট কল
            },
            child: const Text('হ্যাঁ, লগআউট করুন'),
          ),
        ],
      ),
    );
  }
}
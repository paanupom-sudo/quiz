import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Class Cubit Import
import '../class_management/class_cubit.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // ড্যাশবোর্ড লোড হওয়ার সাথেই ক্লাসের ডেটা ফেচ করা হবে
    context.read<ClassCubit>().loadClasses();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    final isTablet = MediaQuery.of(context).size.width >= 650 && !isDesktop;

    int crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Section
            Text(
              'সিস্টেম ওভারভিউ 📊',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'আপনার লার্নিং ম্যানেজমেন্ট সিস্টেমের বর্তমান অবস্থা',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),

            // 2. Statistics Grid
            BlocBuilder<ClassCubit, ClassState>(
              builder: (context, state) {
                // ডাটাবেস থেকে আসা ক্লাসের সংখ্যা বের করা
                String totalClasses = '...';
                if (state is ClassLoaded) {
                  totalClasses = state.classes.length.toString();
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isDesktop ? 1.5 : 1.8,
                  children: [
                    _buildStatCard(
                      context,
                      title: 'মোট স্টুডেন্ট',
                      value: '১,২৪০', // TODO: Student Cubit থেকে আসবে
                      icon: Icons.people_alt_rounded,
                      color: Colors.blue,
                      trend: '+১২% এই মাসে',
                    ),
                    _buildStatCard(
                      context,
                      title: 'মোট ক্লাস',
                      value: totalClasses, // রিয়েল ডেটা
                      icon: Icons.class_rounded,
                      color: Colors.orange,
                      trend: state is ClassLoaded ? 'আপডেটেড' : 'লোড হচ্ছে...',
                    ),
                    _buildStatCard(
                      context,
                      title: 'মোট কুইজ',
                      value: '৪৫০', // TODO: Quiz Cubit থেকে আসবে
                      icon: Icons.quiz_rounded,
                      color: Colors.purple,
                      trend: '+৩০ নতুন যোগ হয়েছে',
                    ),
                    _buildStatCard(
                      context,
                      title: 'মোট আয়',
                      value: '৳ ৪৫,০০০', // TODO: Revenue Cubit থেকে আসবে
                      icon: Icons.monetization_on_rounded,
                      color: Colors.green,
                      trend: '+১৫% গত মাসের চেয়ে',
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 32),

            // 3. Recent Activity Section (Placeholder)
            Text(
              'সাম্প্রতিক কার্যক্রম',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: const Center(
                child: Text('এখানে অ্যাক্টিভিটি গ্রাফ বা লিস্ট বসবে (পরবর্তী ধাপে)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // স্ট্যাটিস্টিক্স কার্ড বানানোর রিইউজেবল উইজেট
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Icon(Icons.more_vert, color: theme.iconTheme.color?.withOpacity(0.5)),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trend,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
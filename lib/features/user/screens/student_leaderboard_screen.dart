import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/profile_model.dart';
import '../../auth/cubit/auth_cubit.dart';

class StudentLeaderboardScreen extends StatefulWidget {
  const StudentLeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentLeaderboardScreen> createState() => _StudentLeaderboardScreenState();
}

class _StudentLeaderboardScreenState extends State<StudentLeaderboardScreen> {
  bool _isLoading = true;
  List<ProfileModel> _leaderboard = [];
  int _myRank = 0;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      // ১. বর্তমান ইউজারের প্রোফাইল থেকে তার 'classId' বের করা
      final authState = context.read<AuthCubit>().state;
      String? myClassId;
      String myId = '';

      if (authState is Authenticated) {
        myClassId = authState.profile.selectedClassId;
        myId = authState.profile.id;
      }

      if (myClassId == null) {
        setState(() => _isLoading = false);
        return; // যদি ক্লাস সিলেক্ট করা না থাকে
      }

      // ২. Supabase থেকে শুধুমাত্র "নিজের ক্লাসের" টপ ৫০ জন স্টুডেন্টকে আনা হচ্ছে
      final response = await Supabase.instance.client
          .from(AppConstants.profilesTable)
          .select()
          .eq('role', 'student')
          .eq('selected_class_id', myClassId) // <-- এই লাইনটি ক্লাস অনুযায়ী ফিল্টার করবে
          .order('xp', ascending: false)
          .limit(50);

      final List<ProfileModel> fetchedUsers = (response as List)
          .map((data) => ProfileModel.fromJson(data))
          .toList();

      // ৩. বর্তমান ইউজারের র‍্যাংক বের করা
      int myCurrentRank = 0;
      final myIndex = fetchedUsers.indexWhere((user) => user.id == myId);
      if (myIndex != -1) {
        myCurrentRank = myIndex + 1;
      }

      setState(() {
        _leaderboard = fetchedUsers;
        _myRank = myCurrentRank;
        _isLoading = false;
      });
    } catch (e) {
      print("Leaderboard Fetch Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('ক্লাস লিডারবোর্ড 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLeaderboard,
              child: _leaderboard.isEmpty
                  ? const Center(child: Text('তোমার ক্লাসে এখনো কেউ কুইজ দেয়নি!'))
                  : Column(
                      children: [
                        // 1. Top 3 Podium Section
                        if (_leaderboard.isNotEmpty)
                          _buildPodiumSection(theme, isDark),
                        
                        const SizedBox(height: 16),

                        // 2. Rest of the Leaderboard List
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: _leaderboard.length > 3 ? _leaderboard.length - 3 : 0,
                            itemBuilder: (context, index) {
                              final user = _leaderboard[index + 3];
                              final rank = index + 4;
                              return _buildLeaderboardTile(theme, isDark, user, rank);
                            },
                          ),
                        ),

                        // 3. Current User Sticky Rank (Bottom)
                        if (_myRank > 0)
                          _buildMyRankStickyBar(theme, isDark),
                      ],
                    ),
            ),
    );
  }

  // --- UI Components ---

  Widget _buildPodiumSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (_leaderboard.length >= 2)
            _buildPodiumAvatar(theme, _leaderboard[1], 2, Colors.blueGrey.shade300, 80),
          
          // 1st Place (Winner)
          if (_leaderboard.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildPodiumAvatar(theme, _leaderboard[0], 1, Colors.amber, 110),
            ),
          
          // 3rd Place
          if (_leaderboard.length >= 3)
            _buildPodiumAvatar(theme, _leaderboard[2], 3, Colors.brown.shade400, 80),
        ],
      ),
    );
  }

  Widget _buildPodiumAvatar(ThemeData theme, ProfileModel user, int rank, Color color, double height) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S';
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (rank == 1) const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 40),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: height,
              width: height,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: Border.all(color: color, width: rank == 1 ? 4 : 2),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(fontSize: rank == 1 ? 40 : 28, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Text(
                '$rank',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.name.split(' ')[0], // শুধু নামের প্রথম অংশ দেখাবে
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${user.xp} XP',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(ThemeData theme, bool isDark, ProfileModel user, int rank) {
    final authState = context.read<AuthCubit>().state;
    bool isMe = false;
    if (authState is Authenticated) {
      isMe = authState.profile.id == user.id;
    }
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isMe ? theme.colorScheme.primary.withOpacity(0.1) : (isDark ? const Color(0xFF1E1E2C) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isMe ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            const SizedBox(width: 16),
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
              child: Text(initial, style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        title: Text(user.name, style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text('${user.xp}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRankStickyBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('আমার র‍্যাংক', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('#$_myRank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                // TODO: কুইজ পেজে নিয়ে যাওয়া
              },
              icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
              label: const Text('XP বাড়াও', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
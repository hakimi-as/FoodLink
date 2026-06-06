import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_route.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/leaderboard_service.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/app_empty_state.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _service = LeaderboardService();

  List<UserModel>? _donors;
  List<UserModel>? _students;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final donors = await _service.topDonors();
    final students = await _service.topStudents();
    if (!mounted) return;
    setState(() {
      _donors = donors;
      _students = students;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final me = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        foregroundColor: c.text,
        title: Text('Leaderboard 🏆', style: GoogleFonts.sora(
            fontWeight: FontWeight.w700, color: c.text)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: c.muted,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [Tab(text: 'Top Donors'), Tab(text: 'Top Students')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LeaderboardList(
            users: _donors,
            pointsOf: (u) => u.donorPoints,
            pointsLabel: 'meals donated',
            emptyEmoji: '🎁',
            emptyTitle: 'No donors ranked yet',
            meId: me?.uid,
          ),
          _LeaderboardList(
            users: _students,
            pointsOf: (u) => u.studentPoints,
            pointsLabel: 'pickups completed',
            emptyEmoji: '🎓',
            emptyTitle: 'No students ranked yet',
            meId: me?.uid,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<UserModel>? users;
  final int Function(UserModel) pointsOf;
  final String pointsLabel;
  final String emptyEmoji;
  final String emptyTitle;
  final String? meId;

  const _LeaderboardList({
    required this.users,
    required this.pointsOf,
    required this.pointsLabel,
    required this.emptyEmoji,
    required this.emptyTitle,
    required this.meId,
  });

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final list = users;
    if (list == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (list.isEmpty) {
      return AppEmptyState(emoji: emptyEmoji, title: emptyTitle, subtitle: 'Check back soon!');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final u = list[i];
        final isMe = u.uid == meId;
        final rank = i + 1;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primaryLight : c.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isMe ? AppColors.primary.withOpacity(0.4) : c.border,
                width: isMe ? 1.5 : 1),
          ),
          child: Row(children: [
            SizedBox(
              width: 36,
              child: Text(
                rank <= 3 ? _medals[rank - 1] : '#$rank',
                textAlign: TextAlign.center,
                style: rank <= 3
                    ? const TextStyle(fontSize: 20)
                    : GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: c.muted),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: (u.photoUrl != null && u.photoUrl!.isNotEmpty)
                  ? NetworkImage(u.photoUrl!)
                  : null,
              child: (u.photoUrl == null || u.photoUrl!.isEmpty)
                  ? Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                      style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: AppColors.primary))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(child: Text(u.name, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: c.text))),
                    if (u.isVerified) ...[
                      const SizedBox(width: 4),
                      const VerifiedBadge(size: 13),
                    ],
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Text('(you)', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.primary)),
                    ],
                  ]),
                  Text(pointsLabel, style: GoogleFonts.dmSans(fontSize: 11, color: c.muted)),
                ],
              ),
            ),
            Text('${pointsOf(u)}', style: GoogleFonts.sora(
                fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ]),
        );
      },
    );
  }
}

void openLeaderboard(BuildContext context) {
  Navigator.of(context).push(AppRoute(builder: (_) => const LeaderboardScreen()));
}

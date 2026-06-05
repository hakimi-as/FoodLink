import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notif> _notifs = [
    _Notif(
      type: _NType.claim,
      title: 'Food Claimed!',
      body: 'Ahmad Razif has reserved 3 portions of Nasi Lemak Ayam Berempah. Please prepare for pickup.',
      time: '2 minutes ago',
      unread: true,
    ),
    _Notif(
      type: _NType.remind,
      title: 'Expiry Reminder ⏰',
      body: 'Your listing Mixed Rice Lauk Pauk expires in 1 hour. It still has 2 portions remaining.',
      time: '28 minutes ago',
      unread: true,
    ),
    _Notif(
      type: _NType.verify,
      title: 'Pickup Verified ✓',
      body: 'Siti Nurhaliza confirmed pickup of 5 portions of Mixed Rice Lauk Pauk. Great work!',
      time: '1 hour ago',
      unread: true,
    ),
    _Notif(
      type: _NType.newFood,
      title: 'New Food Near You 🍛',
      body: 'Hotel Pullman KL just posted 20 portions of Mixed Rice 0.8km away. Claim it before it\'s gone!',
      time: '3 hours ago',
      unread: false,
    ),
    _Notif(
      type: _NType.claim,
      title: 'Claim Successful 🎉',
      body: 'You successfully claimed Artisan Bread & Pastries from AEON Bakehouse. Don\'t forget to pick up!',
      time: 'Yesterday, 4:15 PM',
      unread: false,
    ),
    _Notif(
      type: _NType.newFood,
      title: 'Top Donor This Week 🏆',
      body: 'Congratulations! You\'re ranked #1 Donor this week with 24 meals redistributed. Keep it up!',
      time: 'Yesterday, 12:00 PM',
      unread: false,
    ),
    _Notif(
      type: _NType.remind,
      title: 'Weekly Impact Report',
      body: 'This week you helped save 18.4kg of food from waste and contributed to 54 meals. View full report.',
      time: 'Yesterday, 9:00 AM',
      unread: false,
    ),
  ];

  void _markAll() => setState(() {
        for (final n in _notifs) {
          n.unread = false;
        }
      });

  @override
  Widget build(BuildContext context) {
    final todayItems = _notifs.where((n) => !n.time.startsWith('Yesterday')).toList();
    final yesterdayItems = _notifs.where((n) => n.time.startsWith('Yesterday')).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              color: AppColors.card,
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.arrow_back,
                          size: 16, color: AppColors.bodyText),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Notifications',
                        style: GoogleFonts.sora(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),
                  ),
                  TextButton(
                    onPressed: _markAll,
                    child: Text('Mark all read',
                        style: GoogleFonts.dmSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                children: [
                  _dateLabel('Today'),
                  ...todayItems.map((n) => _NotifTile(
                      notif: n,
                      onTap: () =>
                          setState(() => n.unread = false))),
                  _dateLabel('Yesterday'),
                  ...yesterdayItems.map((n) => _NotifTile(
                      notif: n,
                      onTap: () =>
                          setState(() => n.unread = false))),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.7,
          ),
        ),
      );
}

enum _NType { claim, remind, newFood, verify }

class _Notif {
  final _NType type;
  final String title, body, time;
  bool unread;
  _Notif(
      {required this.type,
      required this.title,
      required this.body,
      required this.time,
      required this.unread});
}

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;
  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final config = _iconConfig(notif.type);

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: notif.unread
                ? AppColors.primary.withOpacity(0.04)
                : Colors.transparent,
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: config.colors),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(config.icon,
                      color: config.iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif.title,
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                              height: 1.3)),
                      const SizedBox(height: 3),
                      Text(notif.body,
                          style: GoogleFonts.dmSans(
                              fontSize: 12.5,
                              color: AppColors.muted,
                              height: 1.5)),
                      const SizedBox(height: 4),
                      Text(notif.time,
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                if (notif.unread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
        const Divider(
            height: 1, color: AppColors.border, indent: 22, endIndent: 22),
      ],
    );
  }

  _IconConfig _iconConfig(_NType t) {
    switch (t) {
      case _NType.claim:
        return _IconConfig(
          colors: [const Color(0xFFDCFCE7), AppColors.green],
          icon: Icons.check_circle,
          iconColor: AppColors.greenDark,
        );
      case _NType.remind:
        return _IconConfig(
          colors: [AppColors.primaryLight, AppColors.primary],
          icon: Icons.access_time,
          iconColor: AppColors.primary,
        );
      case _NType.newFood:
        return _IconConfig(
          colors: [const Color(0xFFEFF6FF), const Color(0xFF3B82F6)],
          icon: Icons.restaurant,
          iconColor: const Color(0xFF2563EB),
        );
      case _NType.verify:
        return _IconConfig(
          colors: [const Color(0xFFF5F3FF), const Color(0xFF8B5CF6)],
          icon: Icons.assignment_turned_in,
          iconColor: const Color(0xFF7C3AED),
        );
    }
  }
}

class _IconConfig {
  final List<Color> colors;
  final IconData icon;
  final Color iconColor;
  const _IconConfig(
      {required this.colors,
      required this.icon,
      required this.iconColor});
}

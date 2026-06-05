import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/claim_provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/app_empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final auth = context.watch<AuthProvider>();
    final claim = context.watch<ClaimProvider>();
    final food = context.watch<FoodProvider>();
    final user = auth.user;

    if (user == null) return const SizedBox.shrink();

    // Build notification items from real Firestore data
    final List<_NotifItem> items = [];

    if (user.isDonor) {
      // Donors see: who claimed their food
      for (final c in claim.donorClaims) {
        items.add(_NotifItem(
          type: _NType.claim,
          title: 'Food Claimed!',
          body:
              '${c.studentName} reserved ${c.quantity} portion(s) of ${c.itemTitle}. Prepare for pickup.',
          time: _formatTime(c.timestamp),
          isUnread: c.isPending,
        ));
      }
      // Donors see: expiry reminders for items expiring within 2h
      for (final item in food.donorItems) {
        final diff = item.expiryTime.difference(DateTime.now());
        if (diff.inHours <= 2 && diff.isNegative == false && item.quantity > 0) {
          items.add(_NotifItem(
            type: _NType.remind,
            title: 'Expiry Reminder ⏰',
            body:
                'Your listing "${item.title}" expires in ${diff.inHours > 0 ? '${diff.inHours}h' : '${diff.inMinutes}m'}. Still has ${item.quantity} portion(s).',
            time: 'Expiring soon',
            isUnread: true,
          ));
        }
      }
    } else if (user.isStudent) {
      // Students see: their own claim history
      for (final c in claim.myClaims) {
        items.add(_NotifItem(
          type: c.isCompleted ? _NType.verify : _NType.claim,
          title: c.isCompleted ? 'Pickup Verified ✓' : 'Claim Successful 🎉',
          body: c.isCompleted
              ? 'Your pickup of ${c.quantity} portion(s) of "${c.itemTitle}" was verified.'
              : 'You claimed ${c.quantity} portion(s) of "${c.itemTitle}" from ${c.donorName}. Please pick up!',
          time: _formatTime(c.timestamp),
          isUnread: c.isPending,
        ));
      }
      // Students see: new food posted recently (last 24h)
      final cutoff = DateTime.now().subtract(const Duration(hours: 24));
      for (final item in food.feed.where((i) => i.createdAt.isAfter(cutoff))) {
        items.add(_NotifItem(
          type: _NType.newFood,
          title: 'New Food Near You 🍛',
          body:
              '${item.donorName} just posted ${item.quantity} portion(s) of "${item.title}" at ${item.pickupLocation}.',
          time: item.postedAgo,
          isUnread: false,
        ));
      }
    } else if (user.isAdmin) {
      // Admins see: all recent claims
      for (final c in claim.allClaims.take(20)) {
        items.add(_NotifItem(
          type: _NType.claim,
          title: 'New Claim',
          body:
              '${c.studentName} claimed ${c.quantity} portion(s) of "${c.itemTitle}".',
          time: _formatTime(c.timestamp),
          isUnread: c.isPending,
        ));
      }
    }

    // Sort: unread first, then by recency (already sorted by timestamp from provider)
    items.sort((a, b) {
      if (a.isUnread && !b.isUnread) return -1;
      if (!a.isUnread && b.isUnread) return 1;
      return 0;
    });

    return _NotificationsView(items: items);
  }
}

String _formatTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
  if (diff.inHours < 24) return '${diff.inHours} hour(s) ago';
  return '${diff.inDays} day(s) ago';
}

// ── Data model ───────────────────────────────────────────────────────────────
enum _NType { claim, remind, newFood, verify }

class _NotifItem {
  final _NType type;
  final String title, body, time;
  bool isUnread;
  _NotifItem({
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
  });
}

// ── View ─────────────────────────────────────────────────────────────────────
class _NotificationsView extends StatefulWidget {
  final List<_NotifItem> items;
  const _NotificationsView({required this.items});

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  late List<_NotifItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  void _markAll() => setState(() {
        for (final n in _items) {
          n.isUnread = false;
        }
      });

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              color: Theme.of(context).cardColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: c.elevated,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(Icons.arrow_back,
                          size: 16, color: c.bodyText),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Notifications',
                        style: GoogleFonts.sora(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: c.text)),
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
            Divider(height: 1, color: c.border),
            Expanded(
              child: _items.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (_, i) => _NotifTile(
                        notif: _items[i],
                        onTap: () =>
                            setState(() => _items[i].isUnread = false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => const Center(
        child: AppEmptyState(
          emoji: '🔔',
          title: 'All caught up',
          subtitle: 'Activity will appear here.',
        ),
      );
}

class _NotifTile extends StatelessWidget {
  final _NotifItem notif;
  final VoidCallback onTap;
  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final cfg = _iconConfig(notif.type);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: notif.isUnread
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
                    gradient: LinearGradient(colors: cfg.colors),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(cfg.icon, color: cfg.iconColor, size: 20),
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
                              color: c.text,
                              height: 1.3)),
                      const SizedBox(height: 3),
                      Text(notif.body,
                          style: GoogleFonts.dmSans(
                              fontSize: 12.5,
                              color: c.muted,
                              height: 1.5)),
                      const SizedBox(height: 4),
                      Text(notif.time,
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: c.muted)),
                    ],
                  ),
                ),
                if (notif.isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: c.border, indent: 22, endIndent: 22),
      ],
    );
  }

  _IconCfg _iconConfig(_NType t) {
    switch (t) {
      case _NType.claim:
        return _IconCfg(
            colors: [const Color(0xFFDCFCE7), AppColors.green],
            icon: Icons.check_circle,
            iconColor: AppColors.greenDark);
      case _NType.remind:
        return _IconCfg(
            colors: [AppColors.primaryLight, AppColors.primary],
            icon: Icons.access_time,
            iconColor: AppColors.primary);
      case _NType.newFood:
        return _IconCfg(
            colors: [const Color(0xFFEFF6FF), const Color(0xFF3B82F6)],
            icon: Icons.restaurant,
            iconColor: const Color(0xFF2563EB));
      case _NType.verify:
        return _IconCfg(
            colors: [const Color(0xFFF5F3FF), const Color(0xFF8B5CF6)],
            icon: Icons.assignment_turned_in,
            iconColor: const Color(0xFF7C3AED));
    }
  }
}

class _IconCfg {
  final List<Color> colors;
  final IconData icon;
  final Color iconColor;
  const _IconCfg(
      {required this.colors, required this.icon, required this.iconColor});
}

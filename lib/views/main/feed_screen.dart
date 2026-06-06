import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_route.dart';
import '../../providers/auth_provider.dart';
import '../../providers/claim_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/food_card.dart';
import '../../widgets/claim_modal.dart';
import '../../widgets/skeleton_food_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/filter_sheet.dart';
import '../secondary/notifications_screen.dart';
import '../secondary/leaderboard_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  static const _chips = ['All', 'Near Me', 'Expiring Soon', 'Halal', 'Vegan'];

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final auth = context.watch<AuthProvider>();
    final food = context.watch<FoodProvider>();
    final claim = context.watch<ClaimProvider>();
    final stats = context.watch<StatsProvider>();
    final user = auth.user;
    final unreadCount = user == null
        ? 0
        : user.isDonor
            ? claim.donorClaims.where((c) => c.isPending).length
            : user.isStudent
                ? claim.myClaims.where((c) => c.isPending).length
                : 0;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning 👋'
        : hour < 17
            ? 'Good afternoon 👋'
            : 'Good evening 👋';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header
            Container(
              color: c.background,
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(greeting,
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: c.muted)),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.sora(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: c.text),
                                children: [
                                  const TextSpan(text: 'Find '),
                                  TextSpan(
                                    text: 'Free Food',
                                    style: GoogleFonts.sora(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Leaderboard
                      GestureDetector(
                        onTap: () => openLeaderboard(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: c.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: c.border, width: 1.5),
                          ),
                          child: Icon(Icons.emoji_events_outlined,
                              size: 18, color: c.bodyText),
                        ),
                      ),
                      // Notification bell
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            AppRoute(builder: (_) => const NotificationsScreen())),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: c.border, width: 1.5),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.notifications_none,
                                  size: 18, color: c.bodyText),
                              if (unreadCount > 0)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: unreadCount > 9 ? 16 : 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: c.card, width: 1.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      unreadCount > 9 ? '9+' : '$unreadCount',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 7,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          image: auth.user?.photoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(auth.user!.photoUrl!),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: auth.user?.photoUrl == null
                            ? Text(
                                auth.user?.name.isNotEmpty == true
                                    ? auth.user!.name[0].toUpperCase()
                                    : 'U',
                                style: GoogleFonts.sora(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ── Impact strip
                  _ImpactStrip(
                    meals: stats.mealsClaimed,
                    kgSaved: stats.kgSaved,
                    co2: stats.co2Saved,
                  ),
                  const SizedBox(height: 12),
                  // ── Search bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: c.border, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search,
                            color: Color(0xFF94A3B8), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: food.setSearch,
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: c.text),
                            decoration: InputDecoration(
                              hintText: 'Search food, location...',
                              hintStyle: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: const Color(0xFFCBD5E1)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            FilterSheet.show(
                              context,
                              initialFilter: food.filter,
                              onApply: food.setFilter,
                            );
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: food.filter.activeCount > 0
                                      ? AppColors.primary
                                      : c.elevated,
                                  borderRadius: BorderRadius.circular(10),
                                  border: food.filter.activeCount == 0
                                      ? Border.all(color: c.border, width: 1.5)
                                      : null,
                                ),
                                child: Icon(Icons.tune,
                                    color: food.filter.activeCount > 0
                                        ? Colors.white
                                        : c.muted,
                                    size: 15),
                              ),
                              if (food.filter.activeCount > 0)
                                Positioned(
                                  top: -4,
                                  right: 4,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${food.filter.activeCount}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Chips
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                itemCount: _chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final chip = _chips[i];
                  final active = food.activeChip == chip;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      food.setChip(chip);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 34,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: active ? c.text : c.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? c.text : c.border,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(chip,
                          style: GoogleFonts.dmSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: active
                                ? Colors.white
                                : c.muted,
                          )),
                    ),
                  );
                },
              ),
            ),
            // ── Section header
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(22, 20, 22, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Available Now',
                      style: GoogleFonts.sora(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: c.text)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${food.feed.length} items',
                        style: GoogleFonts.dmSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            // ── Food list
            Expanded(
              child: food.loading
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                      itemCount: 4,
                      itemBuilder: (_, __) => const SkeletonFoodCard(),
                    )
                  : food.error != null
                      ? _errorState(context, food.error!)
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            HapticFeedback.lightImpact();
                            await Future.wait([
                              context.read<FoodProvider>().refresh(),
                              Future.delayed(const Duration(milliseconds: 600)),
                            ]);
                          },
                          child: food.feed.isEmpty
                              ? ListView(
                                  children: [
                                    AppEmptyState(
                                      emoji: '🍽️',
                                      title: 'No food available yet',
                                      subtitle: 'Donors are getting ready.\nPull down to refresh or check back soon.',
                                      ctaLabel: 'Refresh Feed',
                                      onCta: () => context.read<FoodProvider>().refresh(),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 22),
                                  itemCount: food.feed.length,
                                  itemBuilder: (ctx, i) {
                                    final item = food.feed[i];
                                    return FoodCard(
                                      item: item,
                                      onPickUp: () => _openClaim(ctx, item),
                                    );
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _openClaim(BuildContext ctx, item) {
    final auth = ctx.read<AuthProvider>();
    if (auth.user?.isDonor == true) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text('Donors cannot claim food.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    ClaimModal.show(ctx, item, () {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.check,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Food Claimed! 🎉',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                Text('Please pick up within 30 minutes',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6))),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ));
    });
  }

  Widget _emptyState(BuildContext context) => AppEmptyState(
        emoji: '🍽️',
        title: 'No food available yet',
        subtitle: 'Donors are getting ready.\nPull down to refresh or check back soon.',
        ctaLabel: 'Refresh Feed',
        onCta: () => context.read<FoodProvider>().refresh(),
      );

  Widget _errorState(BuildContext context, String error) {
    final c = context.clr;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(26),
              ),
              alignment: Alignment.center,
              child: const Text('⚠️',
                  style: TextStyle(fontSize: 36),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            Text('Could not load food',
                style: GoogleFonts.sora(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: c.text)),
            const SizedBox(height: 6),
            Text(
              error.contains('permission-denied')
                  ? 'Firestore permissions not set. Deploy firestore.rules.'
                  : error.contains('failed-precondition')
                      ? 'Missing Firestore index. Run: firebase deploy --only firestore'
                      : 'Check your connection and try again.',
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: c.muted, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactStrip extends StatelessWidget {
  final int meals;
  final int kgSaved;
  final int co2;

  const _ImpactStrip({
    required this.meals,
    required this.kgSaved,
    required this.co2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFED7AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          _StatTile(value: meals, label: 'MEALS', emoji: '🍽️'),
          _Divider(),
          _StatTile(value: kgSaved, label: 'KG SAVED', emoji: '⚖️'),
          _Divider(),
          _StatTile(value: co2, label: 'CO₂ kg', emoji: '🌱'),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int value;
  final String label;
  final String emoji;
  const _StatTile({required this.value, required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (_, v, __) => Text(
              '$v',
              style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFC2410C)),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$emoji $label',
            style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEA580C),
                letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 30,
        color: const Color(0xFFFBBF24).withOpacity(0.5),
        margin: const EdgeInsets.symmetric(horizontal: 6),
      );
}

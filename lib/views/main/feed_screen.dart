import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/food_card.dart';
import '../../widgets/claim_modal.dart';
import '../secondary/notifications_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  static const _chips = ['All', 'Near Me', 'Expiring Soon', 'Halal', 'Vegan'];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final food = context.watch<FoodProvider>();
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning 👋'
        : hour < 17
            ? 'Good afternoon 👋'
            : 'Good evening 👋';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header
            Container(
              color: AppColors.background,
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
                                    color: AppColors.muted)),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.sora(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.dark),
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
                      // Notification bell
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const NotificationsScreen())),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.border, width: 1.5),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.notifications_none,
                                  size: 18, color: AppColors.bodyText),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.card, width: 1.5),
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
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          auth.user?.name.isNotEmpty == true
                              ? auth.user!.name[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // ── Search bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppColors.border, width: 1.5),
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
                                fontSize: 14, color: AppColors.dark),
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
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.tune,
                              color: Colors.white, size: 15),
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
                    onTap: () => food.setChip(chip),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 34,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: active ? AppColors.dark : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? AppColors.dark
                              : AppColors.border,
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
                                : AppColors.muted,
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
                          color: AppColors.dark)),
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
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : food.feed.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22),
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
        backgroundColor: AppColors.dark,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ));
    });
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20)
                  ],
                ),
                child: const Text('🍽️',
                    style: TextStyle(fontSize: 36),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              Text('No food available right now',
                  style: GoogleFonts.sora(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark)),
              const SizedBox(height: 6),
              Text('Check back soon — donors are posting!',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.muted),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

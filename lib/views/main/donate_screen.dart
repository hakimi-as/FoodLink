import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/food_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/claim_provider.dart';
import '../../widgets/status_pill.dart';
import '../post/post_food_screen.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.user == null) return const SizedBox.shrink();

    // Students see a locked view
    if (auth.user!.isStudent) return const _LockedDonateView();

    return const _DonorView();
  }
}

// ── Donor view ──────────────────────────────────────────────────────────────
class _DonorView extends StatelessWidget {
  const _DonorView();

  @override
  Widget build(BuildContext context) {
    final food = context.watch<FoodProvider>();
    final claim = context.watch<ClaimProvider>();

    final posted = food.donorItems.length;
    final claimed = food.donorItems
        .where((i) => i.status == AppConstants.statusClaimed)
        .length;
    final active = food.donorItems
        .where((i) => i.status == AppConstants.statusAvailable)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Dark gradient header
            Container(
              decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient),
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                          children: [
                            const TextSpan(text: 'My '),
                            TextSpan(
                              text: 'Donations',
                              style: GoogleFonts.sora(
                                  color: AppColors.primary2),
                            ),
                            const TextSpan(text: ' 🍴'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            _showVerifyModal(context, claim.donorClaims),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.assignment_turned_in,
                                  color: Color(0xFF4ADE80), size: 14),
                              const SizedBox(width: 6),
                              Text('Verify Pickups',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                          child: _StatCard('📦', '$posted', 'Posted')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _StatCard('✅', '$claimed', 'Claimed')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _StatCard('🔴', '$active', 'Active')),
                    ],
                  ),
                ],
              ),
            ),
            // ── Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active Listings',
                          style: GoogleFonts.sora(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark)),
                      Row(
                        children: [
                          const Icon(Icons.swap_vert,
                              size: 14, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text('Sort',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...food.donorItems
                      .map((item) => _DonationCard(item: item))
                      .toList(),
                  const SizedBox(height: 6),
                  // Add food button
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PostFoodScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryLight,
                            Color(0xFFFFE8DC)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(height: 10),
                          Text('Post New Food',
                              style: GoogleFonts.sora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Text('Help someone in need today',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.primary
                                      .withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerifyModal(BuildContext context, List claims) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VerifyModal(claims: claims),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String number;
  final String label;
  const _StatCard(this.icon, this.number, this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text(number,
                style: GoogleFonts.sora(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 0.6)),
          ],
        ),
      );
}

class _DonationCard extends StatefulWidget {
  final FoodItemModel item;
  const _DonationCard({required this.item});

  @override
  State<_DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<_DonationCard> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final food = context.read<FoodProvider>();

    PillType pillType;
    if (item.quantity <= 0) {
      pillType = PillType.closed;
    } else if (item.quantity <= 2) {
      pillType = PillType.urgent;
    } else {
      pillType = PillType.open;
    }

    Color qtyColor = AppColors.dark;
    if (item.quantity <= 0) qtyColor = const Color(0xFF94A3B8);
    if (item.quantity <= 2 && item.quantity > 0) {
      qtyColor = const Color(0xFFC2410C);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
          BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 24,
              offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumb
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFFED7AA),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Text('🍛',
                    style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: GoogleFonts.sora(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                            height: 1.2)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 11, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(item.pickupLocation,
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.muted),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Posted ${item.postedAgo} · Exp. ${TimeOfDay.fromDateTime(item.expiryTime).format(context)}',
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              // Qty badge
              Column(
                children: [
                  Text('${item.quantity}',
                      style: GoogleFonts.sora(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: qtyColor)),
                  Text('LEFT',
                      style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                          letterSpacing: 0.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusPill(type: pillType),
              // +/- controls
              Row(
                children: [
                  _QtyBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (item.quantity > 0) {
                        food.updateQuantity(
                            item.itemId, item.quantity - 1);
                      }
                    },
                    danger: true,
                  ),
                  const SizedBox(width: 8),
                  _QtyBtn(
                    icon: Icons.add,
                    onTap: () =>
                        food.updateQuantity(item.itemId, item.quantity + 1),
                    danger: false,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
  const _QtyBtn(
      {required this.icon, required this.onTap, required this.danger});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Icon(icon,
              size: 16,
              color: danger ? const Color(0xFFEF4444) : AppColors.dark),
        ),
      );
}

// ── Verify Pickups modal ─────────────────────────────────────────────────────
class _VerifyModal extends StatelessWidget {
  final List claims;
  const _VerifyModal({required this.claims});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Verify Pickups',
                  style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close, size: 16, color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (claims.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No claims to verify yet.',
                  style: GoogleFonts.dmSans(color: AppColors.muted)),
            )
          else
            ...claims.map((c) => _ClaimRow(claim: c)).toList(),
        ],
      ),
    );
  }
}

class _ClaimRow extends StatefulWidget {
  final dynamic claim;
  const _ClaimRow({required this.claim});

  @override
  State<_ClaimRow> createState() => _ClaimRowState();
}

class _ClaimRowState extends State<_ClaimRow> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final isDone = _done || widget.claim.isCompleted;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDone ? AppColors.greenLight : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(isDone ? '✅' : '🍛',
                style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.claim.itemTitle,
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.dark)),
                Text(
                  '${widget.claim.quantity} portions · ${widget.claim.studentName}',
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.greenLight
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDone ? 'Completed' : 'Pending Pickup',
                    style: GoogleFonts.dmSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDone
                            ? AppColors.greenDark
                            : const Color(0xFFC2410C)),
                  ),
                ),
              ],
            ),
          ),
          if (!isDone)
            GestureDetector(
              onTap: () async {
                await context
                    .read<ClaimProvider>()
                    .markCompleted(widget.claim.claimId);
                setState(() => _done = true);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Verify',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Locked view for students ─────────────────────────────────────────────────
class _LockedDonateView extends StatelessWidget {
  const _LockedDonateView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🔒',
                      style: TextStyle(fontSize: 36)),
                ),
                const SizedBox(height: 20),
                Text('Donor Feature',
                    style: GoogleFonts.sora(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark)),
                const SizedBox(height: 8),
                Text(
                  'Only registered donors (café/restaurant owners) can post food. Register as a Donor to access this feature.',
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.muted,
                      height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

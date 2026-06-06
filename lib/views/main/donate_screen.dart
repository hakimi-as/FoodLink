import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_route.dart';
import '../../models/food_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/claim_provider.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/qr_scanner_screen.dart';
import '../../models/claim_model.dart';
import '../post/post_food_screen.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final auth = context.watch<AuthProvider>();

    if (auth.user == null) return const SizedBox.shrink();

    // Students see a locked view
    if (auth.user!.isStudent) return const _LockedDonateView();

    return const _DonorView();
  }
}

enum _SortMode { newest, oldest, mostLeft, leastLeft }

// ── Donor view ──────────────────────────────────────────────────────────────
class _DonorView extends StatefulWidget {
  const _DonorView();

  @override
  State<_DonorView> createState() => _DonorViewState();
}

class _DonorViewState extends State<_DonorView> {
  _SortMode _sort = _SortMode.newest;

  void _showSortSheet() {
    final c = context.clr;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Text('Sort Listings',
                style: GoogleFonts.sora(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: c.text)),
            const SizedBox(height: 16),
            for (final mode in _SortMode.values)
              _SortOption(
                label: _sortLabel(mode),
                icon: _sortIcon(mode),
                selected: _sort == mode,
                onTap: () {
                  setState(() => _sort = mode);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  String _sortLabel(_SortMode m) {
    switch (m) {
      case _SortMode.newest: return 'Newest First';
      case _SortMode.oldest: return 'Oldest First';
      case _SortMode.mostLeft: return 'Most Remaining';
      case _SortMode.leastLeft: return 'Least Remaining';
    }
  }

  IconData _sortIcon(_SortMode m) {
    switch (m) {
      case _SortMode.newest: return Icons.arrow_downward;
      case _SortMode.oldest: return Icons.arrow_upward;
      case _SortMode.mostLeft: return Icons.inventory_2_outlined;
      case _SortMode.leastLeft: return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final food = context.watch<FoodProvider>();
    final claim = context.watch<ClaimProvider>();

    final sorted = List.of(food.donorItems)
      ..sort((a, b) {
        switch (_sort) {
          case _SortMode.newest: return b.createdAt.compareTo(a.createdAt);
          case _SortMode.oldest: return a.createdAt.compareTo(b.createdAt);
          case _SortMode.mostLeft: return b.quantity.compareTo(a.quantity);
          case _SortMode.leastLeft: return a.quantity.compareTo(b.quantity);
        }
      });

    final posted = food.donorItems.length;
    final claimed = food.donorItems
        .where((i) => i.status == AppConstants.statusClaimed)
        .length;
    final active = food.donorItems
        .where((i) => i.status == AppConstants.statusAvailable)
        .length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Dark gradient header
            Container(
              decoration: BoxDecoration(
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
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  await Future.wait([
                    context.read<FoodProvider>().refreshDonorItems(),
                    Future.delayed(const Duration(milliseconds: 600)),
                  ]);
                },
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
                              color: c.text)),
                      GestureDetector(
                        onTap: _showSortSheet,
                        child: Row(
                          children: [
                            Icon(Icons.swap_vert,
                                size: 14, color: c.muted),
                            const SizedBox(width: 4),
                            Text(_sortLabel(_sort),
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (sorted.isEmpty)
                    AppEmptyState(
                      emoji: '📦',
                      title: 'No active listings',
                      subtitle: 'Post your first food donation today!',
                      ctaLabel: 'Post Food',
                      onCta: () => Navigator.push(
                          context,
                          AppRoute(builder: (_) => const PostFoodScreen())),
                    )
                  else
                    ...sorted
                        .map((item) => _DonationCard(item: item))
                        .toList(),
                  const SizedBox(height: 6),
                  // Add food button
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        AppRoute(builder: (_) => const PostFoodScreen())),
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
            ),
          ],
        ),
      ),
    );
  }

  void _showVerifyModal(BuildContext context, List<ClaimModel> claims) {
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
    final c = context.clr;
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

    Color qtyColor = c.text;
    if (item.quantity <= 0) qtyColor = const Color(0xFF94A3B8);
    if (item.quantity <= 2 && item.quantity > 0) {
      qtyColor = const Color(0xFFC2410C);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
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
                            color: c.text,
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
                                  color: c.muted),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Posted ${item.postedAgo} · Exp. ${TimeOfDay.fromDateTime(item.expiryTime).format(context)}',
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: c.muted),
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
                          color: c.muted,
                          letterSpacing: 0.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: c.border, height: 1),
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
  Widget build(BuildContext context) {
    final c = context.clr;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border, width: 1.5),
        ),
        child: Icon(icon,
            size: 16,
            color: danger ? const Color(0xFFEF4444) : c.text),
      ),
    );
  }
}

// ── Verify Pickups modal ─────────────────────────────────────────────────────
class _VerifyModal extends StatelessWidget {
  final List<ClaimModel> claims;
  const _VerifyModal({required this.claims});

  Future<void> _scanToVerify(BuildContext context) async {
    final pending = claims.where((c) => c.isPending).toList();
    if (pending.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No pending pickups to verify yet.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final matched = await Navigator.of(context).push<ClaimModel>(
      MaterialPageRoute(builder: (_) => QrScannerScreen(pendingClaims: pending)),
    );
    if (matched != null && context.mounted) {
      await context.read<ClaimProvider>().markCompleted(matched.claimId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pickup confirmed for "${matched.itemTitle}" 🎉'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
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
                  color: c.border,
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
                      color: c.text)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c.elevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.close, size: 16, color: c.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _scanToVerify(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('Scan Pickup QR Code', style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (claims.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No claims to verify yet.',
                  style: GoogleFonts.dmSans(color: c.muted)),
            )
          else
            ...claims.map((c) => _ClaimRow(claim: c)).toList(),
        ],
      ),
    );
  }
}

class _ClaimRow extends StatefulWidget {
  final ClaimModel claim;
  const _ClaimRow({required this.claim});

  @override
  State<_ClaimRow> createState() => _ClaimRowState();
}

class _ClaimRowState extends State<_ClaimRow> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final isDone = _done || widget.claim.isCompleted;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.elevated,
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
                        color: c.text)),
                Text(
                  '${widget.claim.quantity} portions · ${widget.claim.studentName}',
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: c.muted),
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
    final c = context.clr;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        color: c.text)),
                const SizedBox(height: 8),
                Text(
                  'Only registered donors (café/restaurant owners) can post food. Register as a Donor to access this feature.',
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: c.muted,
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

class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SortOption(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : c.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.primary : c.border,
              width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: selected ? AppColors.primary : c.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primary : c.text)),
            ),
            if (selected)
              const Icon(Icons.check, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

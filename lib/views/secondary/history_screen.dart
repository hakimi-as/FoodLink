import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import '../../providers/auth_provider.dart';
import '../../providers/claim_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/rating_provider.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/rating_sheet.dart';
import '../../models/claim_model.dart';
import '../../models/food_item_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final claim = context.watch<ClaimProvider>();
    final food = context.watch<FoodProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              color: c.card,
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: Column(
                children: [
                  Row(
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
                      Text('History',
                          style: GoogleFonts.sora(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: c.text)),
                    ],
                  ),
                  const SizedBox(height: 0),
                  TabBar(
                    controller: _tabs,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: c.muted,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2.5,
                    labelStyle: GoogleFonts.dmSans(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(
                          icon: Icon(Icons.volunteer_activism, size: 16),
                          text: 'My Claims',
                          iconMargin: EdgeInsets.only(bottom: 4)),
                      Tab(
                          icon: Icon(Icons.storefront, size: 16),
                          text: 'My Donations',
                          iconMargin: EdgeInsets.only(bottom: 4)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.border),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _ClaimsTab(claims: claim.myClaims),
                  _DonationsTab(items: food.donorItems),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimsTab extends StatelessWidget {
  final List<ClaimModel> claims;
  const _ClaimsTab({required this.claims});

  @override
  Widget build(BuildContext context) {
    final total = claims.length;
    final completed = claims.where((c) => c.isCompleted).length;
    final pending = claims.where((c) => c.isPending).length;
    final auth = context.read<AuthProvider>();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _SummaryStrip(items: [
          _SumItem(value: '$total', label: 'Total', color: AppColors.primary),
          _SumItem(
              value: '$completed',
              label: 'Completed',
              color: AppColors.greenDark),
          _SumItem(
              value: '$pending',
              label: 'Pending',
              color: const Color(0xFFC2410C)),
        ]),
        const SizedBox(height: 4),
        if (claims.isEmpty)
          const AppEmptyState(
            emoji: '📋',
            title: 'No claims yet',
            subtitle: 'Start claiming food from the feed!',
          )
        else
          ...claims.map((c) => _ClaimHistoryCard(
                claim: c,
                studentId: auth.user?.uid ?? '',
              )),
      ],
    );
  }
}

class _ClaimHistoryCard extends StatefulWidget {
  final ClaimModel claim;
  final String studentId;
  const _ClaimHistoryCard({required this.claim, required this.studentId});

  @override
  State<_ClaimHistoryCard> createState() => _ClaimHistoryCardState();
}

class _ClaimHistoryCardState extends State<_ClaimHistoryCard> {
  bool? _hasRated;

  @override
  void initState() {
    super.initState();
    if (widget.claim.isCompleted) {
      context
          .read<RatingProvider>()
          .hasRated(widget.claim.claimId, widget.studentId)
          .then((v) {
        if (mounted) setState(() => _hasRated = v);
      });
    }
  }

  void _openRating() {
    HapticFeedback.selectionClick();
    RatingSheet.show(
      context,
      donorId: widget.claim.donorId,
      donorName: widget.claim.donorName,
      studentId: widget.studentId,
      claimId: widget.claim.claimId,
      itemTitle: widget.claim.itemTitle,
      onSubmitted: () => setState(() => _hasRated = true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.claim;
    final canRate =
        c.isCompleted && (_hasRated == false);
    return _HistoryCard(
      emoji: '🍛',
      title: c.itemTitle,
      subtitle: '${_formatDate(c.timestamp)} · ${c.quantity} portions',
      pill: c.isPending ? PillType.pending : PillType.completed,
      rightTop: c.isPending ? 'Pending' : 'Completed',
      rightBottom: c.isPending ? 'Pickup Soon' : 'Done',
      rateButton: canRate
          ? GestureDetector(
              onTap: _openRating,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐',
                        style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text('Rate',
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
              ),
            )
          : (_hasRated == true
              ? Text('Rated ✓',
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greenDark))
              : null),
    );
  }
}

class _DonationsTab extends StatelessWidget {
  final List<FoodItemModel> items;
  const _DonationsTab({required this.items});

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final posted = items.length;
    final claimed =
        items.where((i) => i.quantity < i.originalQuantity).length;
    final saved = items.fold(
        0, (sum, i) => sum + (i.originalQuantity - i.quantity));

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _SummaryStrip(items: [
          _SumItem(
              value: '$posted', label: 'Posted', color: AppColors.greenDark),
          _SumItem(
              value: '$claimed', label: 'Claimed', color: AppColors.primary),
          _SumItem(
              value: '${saved}kg',
              label: 'Food Saved',
              color: const Color(0xFF7C3AED)),
        ]),
        const SizedBox(height: 4),
        if (items.isEmpty)
          const AppEmptyState(
            emoji: '🍱',
            title: 'No donations yet',
            subtitle: 'Post some food for people in need!',
          )
        else
          ...items.map((i) => _HistoryCard(
                emoji: '🍱',
                title: i.title,
                subtitle:
                    '${i.postedAgo} · ${i.quantity}/${i.originalQuantity} portions',
                pill: i.isAvailable ? PillType.live : PillType.completed,
                rightTop: i.isAvailable ? 'Live' : 'Completed',
                rightBottom: i.isAvailable ? 'Active' : 'All Claimed',
              )),
      ],
    );
  }
}

class _SumItem {
  final String value, label;
  final Color color;
  const _SumItem(
      {required this.value, required this.label, required this.color});
}

class _SummaryStrip extends StatelessWidget {
  final List<_SumItem> items;
  const _SummaryStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: items
            .map((i) => Expanded(
                  child: Column(
                    children: [
                      Text(i.value,
                          style: GoogleFonts.sora(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: i.color)),
                      const SizedBox(height: 2),
                      Text(i.label.toUpperCase(),
                          style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: c.muted,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String emoji, title, subtitle, rightTop, rightBottom;
  final PillType pill;
  final Widget? rateButton;
  const _HistoryCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.pill,
    required this.rightTop,
    required this.rightBottom,
    this.rateButton,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: c.isDark ? null : const [
          BoxShadow(
              color: Color(0x07000000), blurRadius: 4, offset: Offset(0, 1)),
          BoxShadow(
              color: Color(0x07000000),
              blurRadius: 20,
              offset: Offset(0, 6)),
        ],
        border: c.isDark ? Border.all(color: c.border, width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFED7AA),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.sora(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: c.text),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 10, color: c.muted),
                    const SizedBox(width: 4),
                    Text(subtitle,
                        style: GoogleFonts.dmSans(
                            fontSize: 11.5, color: c.muted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusPill(type: pill, label: rightTop),
              const SizedBox(height: 6),
              Text(rightBottom,
                  style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.text)),
              if (rateButton != null) ...[
                const SizedBox(height: 6),
                rateButton!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  return '${dt.day}/${dt.month}/${dt.year}';
}

Widget _emptyState(BuildContext context, String title, String subtitle) {
  final c = context.clr;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Column(
      children: [
        const Text('📋', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        Text(title,
            style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.text)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: GoogleFonts.dmSans(fontSize: 13, color: c.muted),
            textAlign: TextAlign.center),
      ],
    ),
  );
}

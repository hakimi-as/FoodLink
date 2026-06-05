import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/claim_provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/status_pill.dart';
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
    final claim = context.watch<ClaimProvider>();
    final food = context.watch<FoodProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              color: AppColors.card,
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
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 16, color: AppColors.bodyText),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text('History',
                          style: GoogleFonts.sora(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark)),
                    ],
                  ),
                  const SizedBox(height: 0),
                  TabBar(
                    controller: _tabs,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.muted,
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
            const Divider(height: 1, color: AppColors.border),
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
    final completed =
        claims.where((c) => c.isCompleted).length;
    final pending = claims.where((c) => c.isPending).length;

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
          _emptyState('No claims yet', 'Start claiming food from the feed!')
        else
          ...claims.map((c) => _HistoryCard(
                emoji: '🍛',
                title: c.itemTitle,
                subtitle:
                    '${_formatDate(c.timestamp)} · ${c.quantity} portions',
                pill: c.isPending ? PillType.pending : PillType.completed,
                rightTop: c.isPending ? 'Pending' : 'Completed',
                rightBottom: 'Donated',
              )),
      ],
    );
  }
}

class _DonationsTab extends StatelessWidget {
  final List<FoodItemModel> items;
  const _DonationsTab({required this.items});

  @override
  Widget build(BuildContext context) {
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
          _emptyState(
              'No donations yet', 'Post some food for people in need!')
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
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
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
                                color: AppColors.muted,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
}

class _HistoryCard extends StatelessWidget {
  final String emoji, title, subtitle, rightTop, rightBottom;
  final PillType pill;
  const _HistoryCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.pill,
    required this.rightTop,
    required this.rightBottom,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Color(0x07000000), blurRadius: 4, offset: Offset(0, 1)),
            BoxShadow(
                color: Color(0x07000000),
                blurRadius: 20,
                offset: Offset(0, 6)),
          ],
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
                          color: AppColors.dark),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 10, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(subtitle,
                          style: GoogleFonts.dmSans(
                              fontSize: 11.5, color: AppColors.muted)),
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
                        color: AppColors.dark)),
              ],
            ),
          ],
        ),
      );
}

String _formatDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  return '${dt.day}/${dt.month}/${dt.year}';
}

Widget _emptyState(String title, String subtitle) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Text('📋', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(title,
              style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark)),
          const SizedBox(height: 6),
          Text(subtitle,
              style:
                  GoogleFonts.dmSans(fontSize: 13, color: AppColors.muted),
              textAlign: TextAlign.center),
        ],
      ),
    );

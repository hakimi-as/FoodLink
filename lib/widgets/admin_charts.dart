import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../models/claim_model.dart';

/// Admin analytics: claims-per-day bar chart + status breakdown donut,
/// both derived client-side from the claims the admin dashboard already streams.
class AdminCharts extends StatelessWidget {
  final List<ClaimModel> claims;

  const AdminCharts({super.key, required this.claims});

  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<int> _last7DaysCounts() {
    final now = DateTime.now();
    final counts = List<int>.filled(7, 0);
    for (final claim in claims) {
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(claim.timestamp.year, claim.timestamp.month, claim.timestamp.day))
          .inDays;
      if (diff >= 0 && diff < 7) counts[6 - diff]++;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final counts = _last7DaysCounts();
    final maxCount = counts.fold<int>(1, (m, v) => v > m ? v : m);
    final pending = claims.where((cl) => cl.isPending).length;
    final completed = claims.where((cl) => cl.isCompleted).length;
    final other = claims.length - pending - completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChartCard(
          title: 'Claims — Last 7 Days',
          child: SizedBox(
            height: 140,
            child: BarChart(BarChartData(
              maxY: (maxCount + 1).toDouble(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    final now = DateTime.now();
                    final day = now.subtract(Duration(days: 6 - i));
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(_weekdayLabels[(day.weekday - 1) % 7],
                          style: GoogleFonts.dmSans(fontSize: 10, color: c.muted)),
                    );
                  },
                )),
              ),
              barGroups: [
                for (int i = 0; i < 7; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: counts[i].toDouble(),
                      color: AppColors.primary,
                      width: 16,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ]),
              ],
            )),
          ),
        ),
        const SizedBox(height: 14),
        _ChartCard(
          title: 'Claim Status Breakdown',
          child: claims.isEmpty
              ? SizedBox(
                  height: 100,
                  child: Center(child: Text('No claims yet', style: GoogleFonts.dmSans(color: c.muted))),
                )
              : Row(children: [
                  SizedBox(
                    height: 120, width: 120,
                    child: PieChart(PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        if (pending > 0)
                          PieChartSectionData(value: pending.toDouble(), color: const Color(0xFFF59E0B),
                              showTitle: false, radius: 22),
                        if (completed > 0)
                          PieChartSectionData(value: completed.toDouble(), color: AppColors.greenDark,
                              showTitle: false, radius: 22),
                        if (other > 0)
                          PieChartSectionData(value: other.toDouble(), color: c.muted,
                              showTitle: false, radius: 22),
                      ],
                    )),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendRow(color: const Color(0xFFF59E0B), label: 'Pending', value: pending),
                        const SizedBox(height: 8),
                        _LegendRow(color: AppColors.greenDark, label: 'Completed', value: completed),
                        if (other > 0) ...[
                          const SizedBox(height: 8),
                          _LegendRow(color: c.muted, label: 'Other', value: other),
                        ],
                      ],
                    ),
                  ),
                ]),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: c.isDark ? Border.all(color: c.border, width: 1) : null,
        boxShadow: c.isDark ? null : const [
          BoxShadow(color: Color(0x07000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: c.text)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  const _LegendRow({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: GoogleFonts.dmSans(fontSize: 12.5, color: c.bodyText))),
      Text('$value', style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.text)),
    ]);
  }
}

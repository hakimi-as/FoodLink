import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

enum PillType { open, urgent, closed, completed, pending, live }

class StatusPill extends StatelessWidget {
  final PillType type;
  final String? label;

  const StatusPill({super.key, required this.type, this.label});

  @override
  Widget build(BuildContext context) {
    final config = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label ?? config.label,
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: config.text,
            ),
          ),
        ],
      ),
    );
  }

  _PillConfig _config() {
    switch (type) {
      case PillType.open:
        return _PillConfig(
          bg: AppColors.greenLight,
          dot: AppColors.green,
          text: AppColors.greenDark,
          label: 'Booking Open',
        );
      case PillType.urgent:
        return _PillConfig(
          bg: const Color(0xFFFFF7ED),
          dot: const Color(0xFFF97316),
          text: const Color(0xFFC2410C),
          label: '⚡ Low Stock',
        );
      case PillType.closed:
        return _PillConfig(
          bg: const Color(0xFFF1F5F9),
          dot: const Color(0xFFCBD5E1),
          text: AppColors.muted,
          label: 'Booking Closed',
        );
      case PillType.completed:
        return _PillConfig(
          bg: AppColors.greenLight,
          dot: AppColors.green,
          text: AppColors.greenDark,
          label: 'Completed',
        );
      case PillType.pending:
        return _PillConfig(
          bg: const Color(0xFFFFF7ED),
          dot: const Color(0xFFF97316),
          text: const Color(0xFFC2410C),
          label: 'Pending',
        );
      case PillType.live:
        return _PillConfig(
          bg: const Color(0xFFEFF6FF),
          dot: AppColors.blue,
          text: const Color(0xFF2563EB),
          label: 'Live',
        );
    }
  }
}

class _PillConfig {
  final Color bg, dot, text;
  final String label;
  const _PillConfig(
      {required this.bg,
      required this.dot,
      required this.text,
      required this.label});
}

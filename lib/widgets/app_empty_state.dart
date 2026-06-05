import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

class AppEmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const AppEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7ED), Color(0xFFFED7AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: c.muted,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (ctaLabel != null && onCta != null) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onCta,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  ctaLabel!,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class HalalBadge extends StatelessWidget {
  final bool small;
  const HalalBadge({super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: AppColors.greenDark.withOpacity(0.88),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '✓ HALAL',
        style: GoogleFonts.dmSans(
          fontSize: small ? 9 : 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

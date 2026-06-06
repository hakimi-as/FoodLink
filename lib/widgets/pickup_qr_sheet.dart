import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/theme/app_colors.dart';
import '../models/claim_model.dart';

/// Bottom sheet shown to a student so the donor can scan their pickup QR code.
class PickupQrSheet extends StatelessWidget {
  final ClaimModel claim;

  const PickupQrSheet({super.key, required this.claim});

  static Future<void> show(BuildContext context, ClaimModel claim) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PickupQrSheet(claim: claim),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 28),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Text('Show this to the donor', style: GoogleFonts.sora(
              fontSize: 18, fontWeight: FontWeight.w700, color: c.text)),
          const SizedBox(height: 6),
          Text('They\'ll scan it to confirm your pickup of "${claim.itemTitle}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 13, color: c.muted)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border, width: 1.5),
            ),
            child: QrImageView(
              data: claim.claimId,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
              dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square, color: Colors.black),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Flexible(child: Text(
                  'Code ID: ${claim.claimId.substring(0, claim.claimId.length.clamp(0, 8))}…',
                  style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))),
            ]),
          ),
        ],
      ),
    );
  }
}

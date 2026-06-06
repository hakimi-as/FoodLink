import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/rating_provider.dart';

class RatingSheet extends StatefulWidget {
  final String donorId;
  final String donorName;
  final String studentId;
  final String claimId;
  final String itemTitle;
  final VoidCallback? onSubmitted;

  const RatingSheet({
    super.key,
    required this.donorId,
    required this.donorName,
    required this.studentId,
    required this.claimId,
    required this.itemTitle,
    this.onSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required String donorId,
    required String donorName,
    required String studentId,
    required String claimId,
    required String itemTitle,
    VoidCallback? onSubmitted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RatingSheet(
        donorId: donorId,
        donorName: donorName,
        studentId: studentId,
        claimId: claimId,
        itemTitle: itemTitle,
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  int _stars = 0;
  bool _submitting = false;
  bool _submitted = false;

  Future<void> _submit() async {
    if (_stars == 0 || _submitting) return;
    HapticFeedback.mediumImpact();
    setState(() => _submitting = true);
    final ok = await context.read<RatingProvider>().submitRating(
          donorId: widget.donorId,
          studentId: widget.studentId,
          claimId: widget.claimId,
          stars: _stars,
        );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _submitting = false;
        _submitted = true;
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.pop(context);
      widget.onSubmitted?.call();
    } else {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to submit rating. Try again.'),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: c.isDark ? Border.all(color: c.border) : null,
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                  color: c.border, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          if (_submitted) ...[
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Thanks for rating!',
                style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenDark)),
            const SizedBox(height: 8),
            Text('Your feedback helps the community.',
                style: GoogleFonts.dmSans(fontSize: 14, color: c.muted)),
          ] else ...[
            const Text('⭐', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 14),
            Text('Rate your experience',
                style: GoogleFonts.sora(
                    fontSize: 20, fontWeight: FontWeight.w700, color: c.text)),
            const SizedBox(height: 6),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.dmSans(fontSize: 13.5, color: c.muted),
                children: [
                  const TextSpan(text: 'How was the food from '),
                  TextSpan(
                    text: widget.donorName,
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600, color: c.text),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('"${widget.itemTitle}"',
                style: GoogleFonts.dmSans(
                    fontSize: 12.5,
                    color: c.muted,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 28),
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _stars;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _stars = i + 1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontSize: filled ? 38 : 32,
                        color: filled ? AppColors.primary : c.border,
                      ),
                      child: Text(filled ? '★' : '☆'),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _stars == 0
                  ? 'Tap a star to rate'
                  : _stars == 5
                      ? 'Outstanding!'
                      : _stars == 4
                          ? 'Great!'
                          : _stars == 3
                              ? 'Okay'
                              : _stars == 2
                                  ? 'Could be better'
                                  : 'Not great',
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: _stars == 0 ? c.muted : AppColors.primary,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _stars > 0 ? _submit : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 52,
                decoration: BoxDecoration(
                  gradient: _stars > 0 ? AppColors.primaryGradient : null,
                  color: _stars == 0 ? c.elevated : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _stars > 0
                      ? [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4))
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        'Submit Rating',
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _stars > 0 ? Colors.white : c.muted),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

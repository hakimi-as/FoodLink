import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/food_item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/claim_provider.dart';

class ClaimModal extends StatefulWidget {
  final FoodItemModel item;
  final VoidCallback onClaimed;

  const ClaimModal({super.key, required this.item, required this.onClaimed});

  static void show(BuildContext context, FoodItemModel item,
      VoidCallback onClaimed) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClaimModal(item: item, onClaimed: onClaimed),
    );
  }

  @override
  State<ClaimModal> createState() => _ClaimModalState();
}

class _ClaimModalState extends State<ClaimModal> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final List<Color> gradColors = [
      const Color(0xFFF97316),
      const Color(0xFFEA580C)
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Claim Food',
                style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark)),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Select how many portions you need',
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppColors.muted)),
          ),
          const SizedBox(height: 24),
          // Food info card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradColors),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🍛', style: TextStyle(fontSize: 28)),
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
                              color: AppColors.dark)),
                      const SizedBox(height: 3),
                      Text(item.donorName,
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: AppColors.muted)),
                      const SizedBox(height: 4),
                      Text('${item.quantity} portions left',
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greenDark)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Qty stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepBtn(Icons.remove, () {
                if (_qty > 1) setState(() => _qty--);
              }),
              const SizedBox(width: 20),
              Text(
                '$_qty',
                style: GoogleFonts.sora(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark),
              ),
              const SizedBox(width: 20),
              _stepBtn(Icons.add, () {
                if (_qty < item.quantity) setState(() => _qty++);
              }),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Max available: ${item.quantity}',
            style: GoogleFonts.dmSans(
                fontSize: 11.5, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 20),
          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Cancel',
                      style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Consumer<ClaimProvider>(
                  builder: (ctx, claimProv, _) => GestureDetector(
                    onTap: claimProv.loading ? null : () => _confirm(ctx),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: claimProv.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : Text('Confirm Claim →',
                              style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext ctx) async {
    final auth = ctx.read<AuthProvider>();
    final claim = ctx.read<ClaimProvider>();
    if (auth.user == null) return;
    final user = auth.user!;
    final item = widget.item;
    final qty = _qty;
    final result = await claim.claimFood(item: item, student: user, quantity: qty);
    if (!mounted) return;
    if (ctx.mounted) Navigator.pop(ctx);
    if (result != null) {
      widget.onClaimed();
    }
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          alignment: Alignment.center,
          child:
              Icon(icon, size: 20, color: AppColors.dark),
        ),
      );
}

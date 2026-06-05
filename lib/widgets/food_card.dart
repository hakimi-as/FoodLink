import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../models/food_item_model.dart';
import 'animated_pressable.dart';
import 'halal_badge.dart';

class FoodCard extends StatelessWidget {
  final FoodItemModel item;
  final VoidCallback onPickUp;

  const FoodCard({super.key, required this.item, required this.onPickUp});

  static const List<List<Color>> _gradients = [
    [Color(0xFFFED7AA), Color(0xFFF97316), Color(0xFFEA580C)],
    [Color(0xFFFEF9C3), Color(0xFFFDE68A), Color(0xFFD97706)],
    [Color(0xFFA7F3D0), Color(0xFF34D399), Color(0xFF059669)],
    [Color(0xFFEDE9FE), Color(0xFFA78BFA), Color(0xFF7C3AED)],
    [Color(0xFFFEE2E2), Color(0xFFF87171), Color(0xFFDC2626)],
    [Color(0xFFDBEAFE), Color(0xFF60A5FA), Color(0xFF2563EB)],
  ];

  static const List<String> _emojis = ['🍛','🍱','🫓','🍜','🍎','🥘','🍲','🥗'];

  List<Color> _gradient() => _gradients[item.title.codeUnitAt(0) % _gradients.length];
  String _emoji()          => _emojis[item.title.codeUnitAt(0) % _emojis.length];

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    final grad = _gradient();

    return AnimatedPressable(
      onTap: onPickUp,
      haptic: HapticFeedbackType.light,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(22),
          border: c.isDark ? Border.all(color: c.border, width: 1) : null,
          boxShadow: c.isDark ? null : const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 8,  offset: Offset(0, 2)),
            BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: SizedBox(
                height: 150, width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.imageUrl.isNotEmpty
                        ? Image.network(item.imageUrl, fit: BoxFit.cover)
                        : Container(
                            decoration: BoxDecoration(gradient: LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                              colors: grad)),
                            alignment: Alignment.center,
                            child: Text(_emoji(), style: const TextStyle(fontSize: 52)),
                          ),
                    // Top badges
                    Positioned(
                      top: 12, left: 12, right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _badge(color: AppColors.greenDark.withOpacity(0.92),
                            child: Row(children: [
                              const Icon(Icons.layers, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text('${item.quantity} left', style: GoogleFonts.dmSans(
                                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ])),
                          _badge(
                            color: item.isUrgent
                                ? Colors.red.shade700.withOpacity(0.88)
                                : Colors.black.withOpacity(0.75),
                            child: Row(children: [
                              Icon(item.isUrgent ? Icons.local_fire_department : Icons.access_time,
                                  color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(item.isUrgent ? 'Exp. soon' : item.timeRemaining,
                                  style: GoogleFonts.dmSans(
                                      color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600)),
                            ])),
                        ],
                      ),
                    ),
                    if (item.isHalal)
                      const Positioned(bottom: 10, left: 12, child: HalalBadge()),
                  ],
                ),
              ),
            ),
            // Card body
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.donorName.toUpperCase(), style: GoogleFonts.dmSans(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.primary, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(item.title, style: GoogleFonts.sora(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: c.text, height: 1.2)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.location_on, size: 11, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(item.pickupLocation, style: GoogleFonts.dmSans(
                        fontSize: 12, color: c.muted)),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Posted ${item.postedAgo}', style: GoogleFonts.dmSans(
                          fontSize: 11, color: c.muted)),
                      AnimatedPressable(
                        onTap: onPickUp,
                        haptic: HapticFeedbackType.none,
                        child: Container(
                          height: 36, padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 10, offset: const Offset(0, 3))],
                          ),
                          alignment: Alignment.center,
                          child: Text('Pick Up →', style: GoogleFonts.dmSans(
                              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge({required Color color, required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
    child: child,
  );
}

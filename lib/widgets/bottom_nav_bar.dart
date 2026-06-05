import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'animated_pressable.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDonor;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isDonor = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: c.card,
        border: Border(top: BorderSide(color: c.border, width: 1)),
        boxShadow: c.isDark
            ? null
            : [const BoxShadow(color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.restaurant, label: 'Pick Up',
              active: currentIndex == 0, onTap: () => onTap(0), c: c),
          _CenterFab(onTap: () => onTap(1), active: currentIndex == 1, c: c),
          _NavItem(icon: Icons.person, label: 'Profile',
              active: currentIndex == 2, onTap: () => onTap(2), c: c),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final FLColors c;

  const _NavItem({required this.icon, required this.label,
      required this.active, required this.onTap, required this.c});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : c.muted;
    return AnimatedPressable(
      onTap: onTap,
      haptic: HapticFeedbackType.light,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.dmSans(
                fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _CenterFab extends StatelessWidget {
  final VoidCallback onTap;
  final bool active;
  final FLColors c;

  const _CenterFab({required this.onTap, required this.active, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedPressable(
          onTap: onTap,
          haptic: HapticFeedbackType.medium,
          child: Container(
            width: 52, height: 52,
            margin: const EdgeInsets.only(bottom: 2),
            transform: Matrix4.translationValues(0, -14, 0),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: c.card, width: 3),
              boxShadow: [BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20, offset: const Offset(0, 6))],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 22),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -14),
          child: Text('Donate', style: GoogleFonts.dmSans(
              fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ],
    );
  }
}

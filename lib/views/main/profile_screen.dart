import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/claim_provider.dart';
import '../../providers/theme_provider.dart';
import '../secondary/history_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final food = context.watch<FoodProvider>();
    final claim = context.watch<ClaimProvider>();
    final theme = context.watch<ThemeProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final donated = food.donorItems.length;
    final claimed = claim.myClaims.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Dark header
                Container(
                  decoration: const BoxDecoration(
                      gradient: AppColors.headerGradient),
                  padding: const EdgeInsets.fromLTRB(22, 50, 22, 72),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profile',
                              style: GoogleFonts.sora(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.15)),
                            ),
                            child: const Icon(Icons.settings,
                                color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Avatar
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary2,
                                  AppColors.green
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF1E293B),
                                  shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '👤',
                                style: GoogleFonts.sora(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.dark, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(user.name,
                          style: GoogleFonts.sora(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(user.email,
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6))),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Color(0xFFFDB59E), size: 13),
                            const SizedBox(width: 6),
                            Text(
                              '${user.role[0].toUpperCase()}${user.role.substring(1)} Account',
                              style: GoogleFonts.dmSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFDB59E)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating stats card
                Positioned(
                  bottom: -44,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                              icon: '🍛',
                              value: '$donated',
                              label: 'Donated',
                              valueColor: AppColors.primary),
                        ),
                        Container(width: 1, height: 60, color: AppColors.border),
                        Expanded(
                          child: _StatItem(
                              icon: '🤲',
                              value: '$claimed',
                              label: 'Claimed',
                              valueColor: AppColors.greenDark),
                        ),
                        Container(width: 1, height: 60, color: AppColors.border),
                        Expanded(
                          child: _StatItem(
                              icon: '🌿',
                              value: '${donated * 2}kg',
                              label: 'Saved',
                              valueColor: const Color(0xFF7C3AED)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Impact banner
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)]),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: const Color(0xFF86EFAC), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Text('🏆',
                            style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Top Donor This Month!',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF15803D))),
                              const SizedBox(height: 2),
                              Text(
                                'You\'ve helped feed ${donated * 3} meals and saved food from waste',
                                style: GoogleFonts.dmSans(
                                    fontSize: 11.5,
                                    color: const Color(0xFF4ADE80),
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Account section
                  _sectionLabel('Account'),
                  const SizedBox(height: 10),
                  _MenuItem(
                    icon: Icons.person_outline,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF3B82F6),
                    title: 'User Details',
                    subtitle: 'Name, email, phone number',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.history,
                    iconBg: const Color(0xFFF0FDF4),
                    iconColor: AppColors.green,
                    title: 'History',
                    subtitle: 'My claims & donations',
                    badge: '${claimed + donated}',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen())),
                  ),
                  // Notification toggle
                  _ToggleItem(
                    icon: Icons.notifications_none,
                    iconBg: const Color(0xFFFAF5FF),
                    iconColor: const Color(0xFFA855F7),
                    title: 'Notifications',
                    subtitle: 'Claims, pickups, alerts',
                    value: true,
                    onChanged: (_) {},
                  ),
                  // Dark mode toggle
                  _ToggleItem(
                    icon: Icons.dark_mode_outlined,
                    iconBg: const Color(0xFFF8FAFC),
                    iconColor: AppColors.muted,
                    title: 'Dark Mode',
                    subtitle: 'Toggle app appearance',
                    value: theme.isDark,
                    onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
                  ),
                  _MenuItem(
                    icon: Icons.info_outline,
                    iconBg: AppColors.primaryLight,
                    iconColor: AppColors.primary,
                    title: 'About FoodLink',
                    subtitle: 'Version 1.0.0 · Terms · Privacy',
                    onTap: () {},
                  ),
                  if (user.isAdmin) ...[
                    const SizedBox(height: 4),
                    _sectionLabel('Administration'),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AdminDashboardScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryLight,
                                Color(0xFFFFE8DC)
                              ]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.shield,
                                  color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Admin Dashboard',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary)),
                                  Text('Manage users, food & claims',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 11.5,
                                          color: AppColors.primary
                                              .withOpacity(0.7))),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: AppColors.primary.withOpacity(0.5),
                                size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Logout
                  GestureDetector(
                    onTap: () => _confirmLogout(context),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.redLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.redBorder, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout,
                              color: AppColors.red, size: 18),
                          const SizedBox(width: 10),
                          Text('Log Out',
                              style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.red)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out',
            style: GoogleFonts.sora(
                fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to log out?',
            style: GoogleFonts.dmSans(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            child: Text('Log Out',
                style: GoogleFonts.dmSans(
                    color: AppColors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.8,
          ),
        ),
      );
}

class _StatItem extends StatelessWidget {
  final String icon, value, label;
  final Color valueColor;
  const _StatItem(
      {required this.icon,
      required this.value,
      required this.label,
      required this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: valueColor)),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted)),
          ],
        ),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 3,
                  offset: Offset(0, 1))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.dmSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark)),
                    Text(subtitle,
                        style: GoogleFonts.dmSans(
                            fontSize: 11.5, color: AppColors.muted)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(badge!,
                      style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              Icon(Icons.chevron_right,
                  color: const Color(0xFFCBD5E1), size: 16),
            ],
          ),
        ),
      );
}

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 3,
                offset: Offset(0, 1))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration:
                  BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.dmSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark)),
                  Text(subtitle,
                      style: GoogleFonts.dmSans(
                          fontSize: 11.5, color: AppColors.muted)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      );
}

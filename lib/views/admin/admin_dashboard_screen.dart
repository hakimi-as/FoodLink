import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/food_provider.dart';
import '../../providers/claim_provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../models/food_item_model.dart';
import '../../models/claim_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _authService = AuthService();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = context.watch<FoodProvider>();
    final claim = context.watch<ClaimProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Dark header
            Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1a1a3e), Color(0xFF0F172A)],
              )),
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15)),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA855F7).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFFA855F7)
                                      .withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.shield,
                                    color: Color(0xFFD8B4FE), size: 11),
                                const SizedBox(width: 5),
                                Text('ADMIN',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFD8B4FE))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Dashboard',
                              style: GoogleFonts.sora(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  // Stats
                  StreamBuilder<List<UserModel>>(
                    stream: _authService.getAllUsers(),
                    builder: (ctx, snap) {
                      final userCount = snap.data?.length ?? 0;
                      return Row(
                        children: [
                          Expanded(
                              child: _AdminStat(
                                  '👥', '$userCount', 'Users')),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _AdminStat('🍛',
                                  '${food.allItems.length}', 'Food Items')),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _AdminStat('✅',
                                  '${claim.allClaims.length}', 'Claims')),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Tabs
            Container(
              color: AppColors.card,
              child: TabBar(
                controller: _tabs,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.muted,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelStyle: GoogleFonts.dmSans(
                    fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(icon: Icon(Icons.group, size: 16), text: 'Manage Users'),
                  Tab(
                      icon: Icon(Icons.restaurant, size: 16),
                      text: 'Manage Food'),
                  Tab(
                      icon: Icon(Icons.assignment, size: 16),
                      text: 'Claims'),
                ],
              ),
            ),
            // Search
            Container(
              color: AppColors.card,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: Color(0xFF94A3B8), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) =>
                                  setState(() => _search = v.toLowerCase()),
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: AppColors.dark),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: GoogleFonts.dmSans(
                                    color: const Color(0xFFCBD5E1),
                                    fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: const Icon(Icons.sort,
                        color: AppColors.muted, size: 16),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _UsersTab(search: _search),
                  _FoodTab(items: food.allItems, search: _search),
                  _ClaimsTab(claims: claim.allClaims),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final String icon, value, label;
  const _AdminStat(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 0.6)),
          ],
        ),
      );
}

// ── Users Tab ──────────────────────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  final String search;
  final _authService = AuthService();
  _UsersTab({required this.search});

  @override
  Widget build(BuildContext context) => StreamBuilder<List<UserModel>>(
        stream: _authService.getAllUsers(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final users = (snap.data ?? [])
              .where((u) =>
                  search.isEmpty ||
                  u.name.toLowerCase().contains(search) ||
                  u.email.toLowerCase().contains(search))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: users.length,
            itemBuilder: (ctx, i) => _UserRow(
              user: users[i],
              onDelete: () => _confirmDelete(ctx, users[i]),
            ),
          );
        },
      );

  void _confirmDelete(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => _DeleteDialog(
        title: 'Delete User?',
        subtitle: 'Delete "${user.name}"? This cannot be undone.',
        onConfirm: () => _authService.deleteUser(user.uid),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDelete;
  const _UserRow({required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color roleBg, roleText;
    String roleLabel;
    IconData roleIcon;

    switch (user.role) {
      case 'donor':
        roleBg = const Color(0xFFFFF7ED);
        roleText = const Color(0xFFC2410C);
        roleLabel = 'Donor';
        roleIcon = Icons.storefront;
        break;
      case 'admin':
        roleBg = const Color(0xFFFAF5FF);
        roleText = const Color(0xFF7C3AED);
        roleLabel = 'Admin';
        roleIcon = Icons.shield;
        break;
      default:
        roleBg = const Color(0xFFEFF6FF);
        roleText = const Color(0xFF1D4ED8);
        roleLabel = 'Receiver';
        roleIcon = Icons.volunteer_activism;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000), blurRadius: 3, offset: Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFDBEAFE), Color(0xFF3B82F6)]),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark)),
                Text(user.email,
                    style: GoogleFonts.dmSans(
                        fontSize: 11.5, color: AppColors.muted)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: roleBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(roleIcon, size: 11, color: roleText),
                          const SizedBox(width: 4),
                          Text(roleLabel,
                              style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: roleText)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.redBorder, width: 1.5),
              ),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.red, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Food Tab ────────────────────────────────────────────────────────────────
class _FoodTab extends StatelessWidget {
  final List<FoodItemModel> items;
  final String search;
  const _FoodTab({required this.items, required this.search});

  @override
  Widget build(BuildContext context) {
    final filtered = items
        .where((i) =>
            search.isEmpty ||
            i.title.toLowerCase().contains(search) ||
            i.donorName.toLowerCase().contains(search))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => _FoodRow(
        item: filtered[i],
        onDelete: () => _confirmDelete(ctx, filtered[i]),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FoodItemModel item) {
    showDialog(
      context: context,
      builder: (_) => _DeleteDialog(
        title: 'Delete Food?',
        subtitle: 'Delete "${item.title}"? This cannot be undone.',
        onConfirm: () =>
            context.read<FoodProvider>().deleteFoodItem(item.itemId),
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  final FoodItemModel item;
  final VoidCallback onDelete;
  const _FoodRow({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color statusBg, statusText, statusDot;
    String statusLabel;

    if (item.isUrgent) {
      statusBg = const Color(0xFFFFF7ED);
      statusText = const Color(0xFFC2410C);
      statusDot = const Color(0xFFFB923C);
      statusLabel = 'Expiring Soon';
    } else if (item.isAvailable) {
      statusBg = AppColors.greenLight;
      statusText = AppColors.greenDark;
      statusDot = AppColors.green;
      statusLabel = 'Available';
    } else {
      statusBg = const Color(0xFFF1F5F9);
      statusText = AppColors.muted;
      statusDot = const Color(0xFF94A3B8);
      statusLabel = 'Fully Claimed';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000), blurRadius: 3, offset: Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFED7AA),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text('🍛', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark)),
                Text('By ${item.donorName}',
                    style: GoogleFonts.dmSans(
                        fontSize: 11.5, color: AppColors.muted)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: statusDot,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(statusLabel,
                              style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: statusText)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.quantity} portions',
                      style: GoogleFonts.dmSans(
                          fontSize: 10.5, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.redBorder, width: 1.5),
              ),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.red, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Claims Tab ───────────────────────────────────────────────────────────────
class _ClaimsTab extends StatelessWidget {
  final List<ClaimModel> claims;
  const _ClaimsTab({required this.claims});

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: claims.length,
        itemBuilder: (_, i) => _ClaimRow(claim: claims[i], index: i + 1),
      );
}

class _ClaimRow extends StatelessWidget {
  final ClaimModel claim;
  final int index;
  const _ClaimRow({required this.claim, required this.index});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x07000000),
                blurRadius: 3,
                offset: Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text('#$index',
                      style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(claim.itemTitle,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.5,
              children: [
                _KV('Receiver', claim.studentName),
                _KV('Quantity', '${claim.quantity} portions'),
                _KV('Claimed At',
                    '${claim.timestamp.hour}:${claim.timestamp.minute.toString().padLeft(2, '0')} ${claim.timestamp.hour >= 12 ? 'PM' : 'AM'}'),
                _KV('Status',
                    claim.isCompleted ? '✓ Completed' : '⏳ Pending',
                    valueColor: claim.isCompleted
                        ? AppColors.greenDark
                        : const Color(0xFFC2410C)),
              ],
            ),
          ],
        ),
      );
}

class _KV extends StatelessWidget {
  final String key2, value;
  final Color? valueColor;
  const _KV(this.key2, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(key2.toUpperCase(),
                style: GoogleFonts.dmSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5)),
            Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.dark),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}

// ── Delete confirmation dialog ────────────────────────────────────────────
class _DeleteDialog extends StatelessWidget {
  final String title, subtitle;
  final Future<void> Function() onConfirm;
  const _DeleteDialog(
      {required this.title,
      required this.subtitle,
      required this.onConfirm});

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('🗑️',
                    style: TextStyle(fontSize: 28),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark)),
              const SizedBox(height: 8),
              Text(subtitle,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.muted,
                      height: 1.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await onConfirm();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.red,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Delete',
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

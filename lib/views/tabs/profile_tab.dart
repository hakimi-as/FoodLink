import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/hover_widgets.dart'; // <--- Using the shared widget file
import '../history_screen.dart';
import '../user_details_screen.dart';
import '../admin_dashboard_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUserModel;
    final isDark = themeProvider.isDarkMode;

    // --- DYNAMIC COLORS ---
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F6);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[500];

    // Safety check
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
        children: [
          // 1. PROFILE OVERVIEW
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.pinkAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: cardColor, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                            ? user.photoUrl!
                            : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                Text(
                  user.role == 'student'
                      ? "Student Account"
                      : (user.role == 'admin' ? "Admin Account" : "Donor Account"),
                  style: TextStyle(fontSize: 14, color: subTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. STATS ROW
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('food_items')
                .where('donorId', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, donatedSnap) {
              int donatedCount = donatedSnap.data?.docs.length ?? 0;
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('claims')
                    .where('studentId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, claimedSnap) {
                  int claimedCount = claimedSnap.data?.docs.length ?? 0;
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "DONATED",
                          "$donatedCount",
                          isDark
                              ? const Color(0xFF332010)
                              : const Color(0xFFFFF7ED),
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          "CLAIMED",
                          "$claimedCount",
                          isDark
                              ? const Color(0xFF102825)
                              : const Color(0xFFF0FDFA),
                          Colors.teal,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),

          // 3. MENU LIST
          _buildMenuButton(
            icon: Icons.person_outline,
            iconColor: Colors.blue,
            iconBgColor: isDark
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.blue[50]!,
            cardColor: cardColor,
            textColor: textColor,
            title: "User Details",
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const UserDetailsScreen()));
            },
          ),
          const SizedBox(height: 16),

          // Notifications Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)
              ],
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: isDark
                        ? Colors.purple.withValues(alpha: 0.2)
                        : Colors.purple[50],
                    shape: BoxShape.circle),
                child: const Icon(Icons.notifications_none,
                    color: Colors.purple),
              ),
              title: Text("Notifications",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: textColor)),
              activeTrackColor: Colors.orange, // FIXED: activeColor -> activeTrackColor
              activeColor: Colors.white,
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
          ),
          const SizedBox(height: 16),

          _buildMenuButton(
            icon: Icons.history,
            iconColor: Colors.green,
            iconBgColor: isDark
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.green[50]!,
            cardColor: cardColor,
            textColor: textColor,
            title: "History",
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          const SizedBox(height: 16),

          // Dark Mode Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)
              ],
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                    shape: BoxShape.circle),
                child: const Icon(Icons.dark_mode_outlined,
                    color: Colors.grey),
              ),
              title: Text("Dark Mode",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: textColor)),
              activeTrackColor: Colors.orange, // FIXED
              activeColor: Colors.white,
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
          ),
          const SizedBox(height: 16),

          _buildMenuButton(
            icon: Icons.info_outline,
            iconColor: Colors.orange,
            iconBgColor: isDark
                ? Colors.orange.withValues(alpha: 0.2)
                : Colors.orange[50]!,
            cardColor: cardColor,
            textColor: textColor,
            title: "About Us",
            onTap: () => _showAboutDialog(context, cardColor, textColor),
          ),
          const SizedBox(height: 40),

          // --- ADMIN BUTTON ---
          if (user.role == 'admin') ...[
            HoverScaler(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminDashboardScreen()));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C1E10)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.orange),
                    SizedBox(width: 8),
                    Text("Admin Dashboard",
                        style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 4. LOG OUT BUTTON
          HoverScaler(
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF3F1515)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Log Out",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildStatCard(
      String label, String count, Color bgColor, Color textColor) {
    return HoverScaler(
      scaleFactor: 1.05,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                    letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color cardColor,
    required Color textColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return HoverScaler(
      onTap: onTap,
      scaleFactor: 1.02,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 16)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, Color bgColor, Color textColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: Text("About MySaveFood", style: TextStyle(color: textColor)),
        content: Text(
            "MySaveFood connects food donors with students to reduce waste.",
            style: TextStyle(color: textColor)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close",
                  style: TextStyle(color: Colors.orange)))
        ],
      ),
    );
  }
}
// NO CLASS HERE - IT IS REMOVED
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../history_screen.dart'; 
import '../login_screen.dart'; 
import '../notifications_screen.dart';
import '../theme_screen.dart'; 

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUserModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
        centerTitle: true,
        elevation: 0,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.person, color: Colors.orange, size: 32),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Details
            _buildProfileOption(
              context, 
              title: "User Details", 
              onTap: () {
                _showUserDetails(context, user?.name ?? "User", user?.email ?? "Email");
              }
            ),
            const SizedBox(height: 16),

            // Notifications
            _buildProfileOption(
              context, 
              title: "Notifications", 
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              }
            ),
             const SizedBox(height: 16),

            // History
            _buildProfileOption(
              context, 
              title: "History", 
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
              }
            ),
             const SizedBox(height: 16),

            // Theme
            _buildProfileOption(
              context, 
              title: "Theme", 
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeScreen()));
              }
            ),
             const SizedBox(height: 16),

            // About Us - UPDATED
            _buildProfileOption(
              context, 
              title: "About Us", 
              onTap: () {
                _showAboutUs(context);
              }
            ),
             const SizedBox(height: 16),

            // Log Out
            _buildProfileOption(
              context, 
              title: "Log Out", 
              onTap: () {
                authProvider.logout();
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {required String title, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxColor = isDark ? Colors.grey[800] : const Color(0xFFFFE0B2);
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: boxColor, 
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: textColor),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  void _showUserDetails(BuildContext context, String name, String email) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("User Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $name"),
            const SizedBox(height: 8),
            Text("Email: $email"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
        ],
      ),
    );
  }

  // NEW: About Us Dialog
  void _showAboutUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("About MySaveFood"),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MySaveFood is a community-driven initiative designed to reduce food waste on campus.",
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 15),
              Text(
                "Our Goal:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("To connect donors with surplus food to students who need it, ensuring that no good food goes to waste."),
              SizedBox(height: 15),
              Text("Version: 1.0.0"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
        ],
      ),
    );
  }
}
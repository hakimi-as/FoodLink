import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'tabs/feed_tab.dart';
import 'tabs/donate_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FeedTab(),
    const DonateTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    final userRole = authProvider.currentUserModel?.role;
    
    // --- OPTION 1: ADMIN GETS DONOR ACCESS ---
    // We treat 'admin' as authorized just like 'donor'
    final isAuthorizedDonor = userRole == 'donor' || userRole == 'admin';
    
    final isDark = themeProvider.isDarkMode;

    // --- Dynamic Colors ---
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAF9);
    final navColor = isDark ? const Color(0xFF1E1E1E).withOpacity(0.9) : Colors.white.withOpacity(0.9);
    final navShadow = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1);
    final iconUnselected = isDark ? Colors.grey[600] : Colors.grey[400];

    return Scaffold(
      extendBody: true, 
      backgroundColor: bgColor,
      
      // Check if user is authorized (Donor OR Admin) to see the Donate Tab
      body: _currentIndex == 1 && !isAuthorizedDonor 
          ? _buildRestrictedAccess(isDark) 
          : _pages[_currentIndex],

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        height: 80,
        decoration: BoxDecoration(
          color: navColor,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: navShadow,
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Pick Up Tab
            _buildNavItem(0, Icons.restaurant_menu, "Pick Up", iconUnselected!),

            // Donate Tab (Middle Button)
            GestureDetector(
              onTap: () => setState(() => _currentIndex = 1),
              child: Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    width: 4
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEA580C).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 28),
              ),
            ),

            // Profile Tab
            _buildNavItem(2, Icons.person_outline, "Profile", iconUnselected),
          ],
        ),
      ),
    );
  }

  // Helper for Nav Items
  Widget _buildNavItem(int index, IconData icon, String label, Color unselectedColor) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFEA580C) : unselectedColor,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFFEA580C) : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }

  // Restriction Widget
  Widget _buildRestrictedAccess(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline, 
            size: 80, 
            color: isDark ? Colors.grey[700] : Colors.grey[300]
          ),
          const SizedBox(height: 20),
          Text(
            "Restricted Access",
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : const Color(0xFF1F2937)
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Only Donors can post food.", 
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500])
          ),
        ],
      ),
    );
  }
}
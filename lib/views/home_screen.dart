import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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

  // This list defines the logic for each tab based on the selected index
  final List<Widget> _pages = [
    const FeedTab(),   // Index 0: Pick Up
    const DonateTab(), // Index 1: Donate
    const ProfileTab(),// Index 2: Profile
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDonor = authProvider.currentUserModel?.role == 'donor';

    return Scaffold(
      appBar: AppBar(
        title: const Text("MySaveFood", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false, // Removes back button
      ),
      body: _currentIndex == 1 && !isDonor 
          ? _buildRestrictedAccess() // If Student tries to access Donate tab
          : _pages[_currentIndex],   // Otherwise show the page
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.rice_bowl),
            label: 'Pick Up',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // This prevents Students from using the Donate Form
  Widget _buildRestrictedAccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.lock_outline, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            "Student Access Restricted",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text("Only Donors can post food."),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/food_item_model.dart';
import '../donate_form_screen.dart';
import '../manage_claims_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/theme_provider.dart';

class DonateTab extends StatelessWidget {
  const DonateTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final donationProvider = Provider.of<DonationProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    final user = authProvider.currentUserModel;
    final currentUserId = user?.uid;
    final isDark = themeProvider.isDarkMode;

    // --- Dynamic Colors ---
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAF9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFE0B2);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[800];

    // --- 1. RESTRICTION VIEW ---
    // Allow access ONLY if role is 'donor' OR 'admin'
    bool isAuthorized = user?.role == 'donor' || user?.role == 'admin';

    if (!isAuthorized) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Donate Food",
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          backgroundColor: bgColor,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline, 
                size: 80, 
                color: isDark ? Colors.grey[600] : Colors.grey[300]
              ),
              const SizedBox(height: 20),
              Text(
                "Restricted Access",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                "Only donors can post food.",
                style: TextStyle(fontSize: 16, color: subTextColor),
              ),
            ],
          ),
        ),
      );
    }

    // --- 2. DONOR/ADMIN DASHBOARD VIEW ---
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "My Donations",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 24),
            ),
            SizedBox(width: 8),
            Icon(Icons.volunteer_activism, color: Colors.orange, size: 30),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_turned_in, color: Colors.green),
            tooltip: "Verify Pickups",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageClaimsScreen()));
            },
          ),
          const SizedBox(width: 10),
        ],
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('food_items')
            .where('donorId', isEqualTo: currentUserId)
            .orderBy('postedTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.hasData ? snapshot.data!.docs : [];

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
            itemCount: docs.length + 1,
            itemBuilder: (context, index) {
              if (index == docs.length) {
                return _buildAddFoodButton(context, isDark);
              }

              final data = docs[index].data() as Map<String, dynamic>;
              FoodItem item;
              try {
                item = FoodItem.fromMap(data);
              } catch (e) {
                return const SizedBox();
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.05), // Fixed deprecation in case you missed it earlier
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text(item.pickupLocation, style: TextStyle(fontSize: 13, color: subTextColor, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text("Posted: ${DateFormat('h:mm a (d MMM)').format(item.postedTime)}", style: TextStyle(fontSize: 12, color: subTextColor)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text("LEFT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                              Text("${item.quantity}", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: isDark ? Colors.grey[800] : Colors.grey[100], height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: item.quantity > 0 
                                  ? (isDark ? const Color(0xFF102825) : const Color(0xFFF0FDFA)) 
                                  : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F4F6)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.quantity > 0 ? "Booking: Allowed" : "Booking: Closed",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: item.quantity > 0 ? const Color(0xFF14B8A6) : Colors.grey[400]),
                            ),
                          ),
                          Row(
                            children: [
                              _buildCircleBtn(
                                icon: Icons.remove,
                                color: Colors.red[400]!,
                                bgColor: isDark ? const Color(0xFF3F1515) : const Color(0xFFFEF2F2),
                                onTap: () => donationProvider.updateFoodQuantity(item.id, item.quantity - 1),
                              ),
                              const SizedBox(width: 12),
                              _buildCircleBtn(
                                icon: Icons.add,
                                color: Colors.green[500]!,
                                bgColor: isDark ? const Color(0xFF102825) : const Color(0xFFF0FDF4),
                                onTap: () => donationProvider.updateFoodQuantity(item.id, item.quantity + 1),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddFoodButton(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateFormScreen())),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.orange.withOpacity(0.1) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isDark) 
                    BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: const Icon(Icons.volunteer_activism, size: 32, color: Colors.orange),
            ),
            const SizedBox(height: 12),
            Text("Add Food", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.orange : const Color(0xFFEA580C))),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn({required IconData icon, required Color color, required Color bgColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/food_item_model.dart';
import '../donate_form_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';

class DonateTab extends StatelessWidget {
  const DonateTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final donationProvider = Provider.of<DonationProvider>(context, listen: false);
    final currentUserId = authProvider.currentUserModel?.uid;

    return Scaffold(
      appBar: AppBar(
        // 1. Center Title & Enlarge Logo/Text
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Donate Food",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontSize: 28, // Bigger Text
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.volunteer_activism,
              color: Colors.orange,
              size: 36, // Bigger Icon
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('food_items')
                  .orderBy('postedTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No donations yet. Be the first!"));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    FoodItem item;
                    try {
                      item = FoodItem.fromMap(data);
                    } catch (e) {
                      return const SizedBox();
                    }

                    // 2. Check if Current User is the Donor
                    bool isMyDonation = item.donorId == currentUserId;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: const Color(0xFFFFE0B2), // Light Orange
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Location: ${item.pickupLocation}", 
                                    style: const TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text("Menu: ${item.title}"),
                                  // Static text as per mockup
                                  const Text("Booking Option: Allow"), 
                                  const SizedBox(height: 8),
                                  Text(
                                    "Post Date: ${DateFormat('h:mm a (d MMM)').format(item.postedTime)}",
                                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                            ),
                            
                            // 3. Show Buttons OR Static Text based on ownership
                            isMyDonation
                                ? _buildDonorControls(context, donationProvider, item)
                                : _buildViewerDisplay(item.quantity),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // "Add Food" Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateFormScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC80),
                foregroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              icon: const Icon(Icons.volunteer_activism, size: 40, color: Colors.grey),
              label: const Text(
                "Add Food", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)
              ),
            ),
          )
        ],
      ),
    );
  }

  // Widget: +/- Buttons for Donor
  Widget _buildDonorControls(BuildContext context, DonationProvider provider, FoodItem item) {
    return Column(
      children: [
        const Text("Left:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text("${item.quantity}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            // Minus Button (Red)
            InkWell(
              onTap: () => provider.updateFoodQuantity(item.id, item.quantity - 1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.red[200], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.remove, size: 16),
              ),
            ),
            const SizedBox(width: 8),
            // Plus Button (Green)
            InkWell(
              onTap: () => provider.updateFoodQuantity(item.id, item.quantity + 1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.green[200], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add, size: 16),
              ),
            ),
          ],
        )
      ],
    );
  }

  // Widget: Static Text for Students/Others
  Widget _buildViewerDisplay(int quantity) {
    return Column(
      children: [
        const Text("Left:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("$quantity", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
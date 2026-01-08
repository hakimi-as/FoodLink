import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/food_item_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../widgets/hover_widgets.dart'; // <--- IMPORT THE NEW WIDGETS

class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final donationProvider =
        Provider.of<DonationProvider>(context, listen: false);

    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAF9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[500];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text("Pick Up Food",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 28)),
            SizedBox(width: 10),
            Icon(Icons.restaurant, color: Colors.orange, size: 30),
          ],
        ),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('food_items')
            .where('status', isEqualTo: 'available')
            .orderBy('postedTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fastfood_outlined,
                      size: 60, color: subTextColor),
                  const SizedBox(height: 16),
                  Text("No food available right now.",
                      style: TextStyle(color: textColor)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              FoodItem item;
              try {
                item = FoodItem.fromMap(data);
              } catch (e) {
                return const SizedBox();
              }

              // --- 1. HOVER SCALER FROM SHARED FILE ---
              return HoverScaler(
                scaleFactor: 1.02,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05), // FIXED
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: Image.network(
                            item.imageUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 150,
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              child: const Center(
                                  child: Icon(Icons.broken_image,
                                      color: Colors.grey)),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(item.title,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1), // FIXED
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text("${item.quantity} Left",
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(item.pickupLocation,
                                    style: TextStyle(
                                        fontSize: 14, color: subTextColor)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Posted: ${DateFormat('h:mm a').format(item.postedTime)}",
                                    style: TextStyle(
                                        fontSize: 12, color: subTextColor)),
                                
                                // --- 2. GRADIENT BUTTON FROM SHARED FILE ---
                                HoverGradientButton(
                                  text: "Pick Up",
                                  width: 100,
                                  height: 40,
                                  onTap: () {
                                    if (item.quantity <= 0) return;
                                    _showClaimDialog(
                                        context,
                                        item,
                                        authProvider,
                                        donationProvider,
                                        isDark);
                                  },
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
            },
          );
        },
      ),
    );
  }

  void _showClaimDialog(
      BuildContext parentContext,
      FoodItem item,
      AuthProvider authProvider,
      DonationProvider donationProvider,
      bool isDark) {
    int claimQuantity = 1;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text("Claim Food",
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Select Quantity to Pickup",
                      style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HoverScaler(
                        scaleFactor: 1.1,
                        onTap: () {
                          if (claimQuantity > 1) {
                            setDialogState(() => claimQuantity--);
                          }
                        },
                        child: const Icon(Icons.remove_circle,
                            color: Colors.red, size: 36),
                      ),
                      const SizedBox(width: 20),
                      Text("$claimQuantity",
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(width: 20),
                      HoverScaler(
                        scaleFactor: 1.1,
                        onTap: () {
                          if (claimQuantity < item.quantity) {
                            setDialogState(() => claimQuantity++);
                          }
                        },
                        child: const Icon(Icons.add_circle,
                            color: Colors.green, size: 36),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Max Available: ${item.quantity}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                
                HoverGradientButton(
                  text: "Confirm",
                  width: 120,
                  height: 45,
                  onTap: () async {
                    try {
                      final currentUser = authProvider.currentUserModel;
                      if (currentUser == null) {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(content: Text("Please login first.")));
                        return;
                      }

                      Navigator.pop(dialogContext);

                      await donationProvider.updateFoodQuantity(
                          item.id, item.quantity - claimQuantity);
                      await FirebaseFirestore.instance
                          .collection('claims')
                          .add({
                        'foodId': item.id,
                        'foodTitle': item.title,
                        'donorId': item.donorId,
                        'studentId': currentUser.uid,
                        'claimedAt': FieldValue.serverTimestamp(),
                        'quantityClaimed': claimQuantity,
                        'status': 'pending',
                      });

                      if (parentContext.mounted) {
                        _showSuccessDialog(
                            parentContext,
                            "Claim Successful!",
                            "You claimed $claimQuantity item(s).\nPlease pick it up soon!",
                            isDark);
                      }
                    } catch (e) {
                      if (parentContext.mounted) {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(content: Text("Error: $e")));
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(
      BuildContext context, String title, String message, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1), // FIXED
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    size: 70, color: Colors.green),
              ),
              const SizedBox(height: 24),
              Text(title,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.5)),
              const SizedBox(height: 32),
              
              HoverGradientButton(
                text: "Awesome",
                colorStart: Colors.green,
                colorEnd: Colors.teal,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
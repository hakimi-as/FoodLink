import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ManageClaimsScreen extends StatelessWidget {
  const ManageClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    final currentUserId = authProvider.currentUserModel?.uid;
    final isDark = themeProvider.isDarkMode;
    
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAF9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Verify Pickups", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('claims')
            .where('donorId', isEqualTo: currentUserId)
            .orderBy('claimedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint("Firestore Query Error: ${snapshot.error}");
            return Center(child: Text("Error loading data. Check console.", style: TextStyle(color: Colors.red)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No claims found.", style: TextStyle(color: textColor)));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final claimId = docs[index].id;
              
              final foodTitle = data['foodTitle'] ?? 'Unknown Item';
              final quantity = data['quantityClaimed'] ?? 1;
              final status = data['status'] ?? 'pending';
              final Timestamp? timestamp = data['claimedAt'];
              final dateStr = timestamp != null 
                  ? DateFormat('MMM d, h:mm a').format(timestamp.toDate()) 
                  : 'Just now';

              final isCompleted = status == 'completed';
              final statusBg = isCompleted 
                  ? Colors.green.withValues(alpha: 0.1) 
                  : Colors.orange.withValues(alpha: 0.1);
              final statusColor = isCompleted ? Colors.green : Colors.orange;
              final statusIcon = isCompleted ? Icons.check_circle : Icons.access_time_filled;

              return Card(
                color: cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0, 
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: statusBg, shape: BoxShape.circle),
                        child: Icon(statusIcon, color: statusColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(foodTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 4),
                            Text("Qty: $quantity • $dateStr", style: TextStyle(color: subTextColor, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                          ],
                        ),
                      ),
                      if (!isCompleted)
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('claims').doc(claimId).update({'status': 'completed'});
                            
                            if (context.mounted) {
                              _showSuccessDialog(context, "Verified!", "The pickup has been marked as completed.", isDark);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Verify", style: TextStyle(color: Colors.white)),
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

  void _showSuccessDialog(BuildContext context, String title, String message, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, size: 70, color: Colors.green),
              ),
              const SizedBox(height: 24),
              Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 8),
              Text(
                message, 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.5)
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("Awesome", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/hover_widgets.dart'; // <--- Using the shared widget file

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final currentUserId = authProvider.currentUserModel?.uid;
    final isDark = themeProvider.isDarkMode;

    // --- Dynamic Colors ---
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAF9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("My Claims",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('claims')
            .where('studentId', isEqualTo: currentUserId)
            .orderBy('claimedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text("No claims history yet.",
                    style: TextStyle(color: textColor)));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final foodTitle = data['foodTitle'] ?? 'Unknown Item';
              final int quantity =
                  data['quantityClaimed'] ?? data['quantity'] ?? 1;

              final status = data['status'] ?? 'pending';
              final Timestamp? timestamp = data['claimedAt'];
              final dateStr = timestamp != null
                  ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
                  : 'Just now';

              // Dynamic Status Colors
              final isCompleted = status == 'completed';
              final statusColor =
                  isCompleted ? Colors.blue : Colors.orange;
              final statusIcon =
                  isCompleted ? Icons.restaurant : Icons.access_time;

              // --- APPLIED HOVER ANIMATION ---
              return HoverScaler(
                scaleFactor: 1.02,
                child: Card(
                  color: cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Icon Status
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C2C2C)
                                : Colors.orange[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon,
                              color: statusColor, size: 24),
                        ),
                        const SizedBox(width: 16),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(foodTitle,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor)),
                              const SizedBox(height: 4),
                              Text("Claimed: $quantity unit(s)",
                                  style: TextStyle(
                                      color: subTextColor, fontSize: 12)),
                              Text("Time: $dateStr",
                                  style: TextStyle(
                                      color: subTextColor, fontSize: 12)),
                            ],
                          ),
                        ),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: statusColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// NO CLASS HERE - IT IS REMOVED
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../models/food_item_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Stream<QuerySnapshot> _historyStream;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDonor = authProvider.currentUserModel?.role == 'donor';
    final uid = authProvider.currentUserModel?.uid;
    
    _historyStream = _getStream(isDonor, uid!);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDonor = authProvider.currentUserModel?.role == 'donor';

    return Scaffold(
      appBar: AppBar(
        title: Text(isDonor ? "My Donations" : "My Claims"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _historyStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    const Text("Database Index Missing", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                      "Please check your debug console and click the link to create the index for '${isDonor ? 'food_items' : 'claims'}'.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No history found."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              String title = "";
              String subtitle = "";
              String status = "";

              if (isDonor) {
                // DONOR VIEW
                try {
                   FoodItem item = FoodItem.fromMap(data);
                   title = item.title;
                   // FIXED: Simplified to just show current quantity
                   subtitle = "Posted: ${DateFormat('MMM d, h:mm a').format(item.postedTime)}\nQty Left: ${item.quantity}";
                   status = item.status.toUpperCase();
                } catch (e) {
                   title = "Unknown Item";
                   status = "UNKNOWN";
                }
              } else {
                // STUDENT VIEW
                title = data['title'] ?? 'Unknown Food';
                Timestamp? ts = data['claimedAt'] as Timestamp?;
                DateTime date = ts != null ? ts.toDate() : DateTime.now();
                int qty = data['quantityClaimed'] ?? 1;
                subtitle = "Claimed: $qty unit(s)\nTime: ${DateFormat('MMM d, h:mm a').format(date)}";
                status = "RESERVED";
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Icon(isDonor ? Icons.volunteer_activism : Icons.fastfood, color: Colors.orange),
                  ),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(subtitle),
                  isThreeLine: true,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'AVAILABLE' ? Colors.green[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: status == 'AVAILABLE' ? Colors.green : Colors.black54,
                      ),
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

  Stream<QuerySnapshot> _getStream(bool isDonor, String uid) {
    final db = FirebaseFirestore.instance;
    if (isDonor) {
      return db.collection('food_items')
          .where('donorId', isEqualTo: uid)
          .orderBy('postedTime', descending: true)
          .snapshots();
    } else {
      return db.collection('claims')
          .where('studentId', isEqualTo: uid)
          .orderBy('claimedAt', descending: true)
          .snapshots();
    }
  }
}
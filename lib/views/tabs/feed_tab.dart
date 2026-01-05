import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../../providers/feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/food_item_model.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  late Stream<List<FoodItem>> _foodStream;

  @override
  void initState() {
    super.initState();
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _foodStream = feedProvider.availableFoodStream;
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Text("Pick Up Food", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.rice_bowl, color: Colors.orange),
          ],
        ),
      ),
      body: StreamBuilder<List<FoodItem>>(
        stream: _foodStream, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No food available right now. Check back later!"));
          }

          final items = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildFoodCard(context, items[index], feedProvider, authProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, FoodItem item, FeedProvider feedProvider, AuthProvider authProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFFFFE0B2), 
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Halal Badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 80, height: 80, color: Colors.grey, 
                          child: const Icon(Icons.broken_image)
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        color: Colors.white.withOpacity(0.8),
                        child: const Text("HALAL", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green)),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Location: ${item.pickupLocation}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Menu: ${item.title}"),
                      const SizedBox(height: 4),
                      Text("Posted: ${DateFormat('h:mm a').format(item.postedTime)}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    ],
                  ),
                ),
                Column(
                  children: [
                    // NEW: Report Button
                    IconButton(
                      icon: const Icon(Icons.flag_outlined, color: Colors.grey, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showReportDialog(context, item.title),
                    ),
                    const SizedBox(height: 8),
                    const Text("Left:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    "Best Before: ${DateFormat('h:mm a').format(item.expiryTime)}",
                    style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent[400], foregroundColor: Colors.black),
                  onPressed: () => _showClaimDialog(context, item, feedProvider, authProvider),
                  child: const Text("Claim", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showClaimDialog(BuildContext context, FoodItem item, FeedProvider feedProvider, AuthProvider authProvider) {
    int quantityToClaim = 1; 

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Claim ${item.title}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("How many packs do you want?"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red, size: 32),
                        onPressed: () {
                          if (quantityToClaim > 1) setState(() => quantityToClaim--);
                        },
                      ),
                      const SizedBox(width: 20),
                      Text("$quantityToClaim", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green, size: 32),
                        onPressed: () {
                          if (quantityToClaim < item.quantity) setState(() => quantityToClaim++);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Max available: ${item.quantity}", style: const TextStyle(color: Colors.grey)),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    String? error = await feedProvider.claimFood(
                      item.id, 
                      authProvider.currentUserModel!.uid,
                      authProvider.currentUserModel!.name,
                      quantityToClaim, 
                    );
                    if (error == null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully claimed $quantityToClaim item(s)!")));
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $error")));
                    }
                  },
                  child: const Text("Confirm"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // NEW: Report Dialog
  void _showReportDialog(BuildContext context, String foodTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Report Item"),
        content: Text("Do you want to report '$foodTitle' for violation (e.g., Not Halal, Fake)?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              // In a real app, you would save this to a 'reports' collection in Firestore
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Report submitted. Admins will review.")));
            },
            child: const Text("Report", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
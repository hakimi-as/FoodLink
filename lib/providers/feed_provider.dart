import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item_model.dart';

class FeedProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<FoodItem>> get availableFoodStream {
    return _db
        .collection('food_items')
        .where('status', isEqualTo: 'available')
        .orderBy('postedTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodItem.fromMap(doc.data()))
            .toList());
  }

  Future<String?> claimFood(String itemId, String studentId, String studentName, int amount) async {
    try {
      await _db.runTransaction((transaction) async {
        DocumentReference itemRef = _db.collection('food_items').doc(itemId);
        DocumentSnapshot itemSnapshot = await transaction.get(itemRef);

        if (!itemSnapshot.exists) throw Exception("Item does not exist!");

        int currentQuantity = itemSnapshot.get('quantity');
        if (currentQuantity < amount) throw Exception("Only $currentQuantity items left!");

        int newQuantity = currentQuantity - amount;
        String newStatus = newQuantity == 0 ? 'claimed' : 'available';
        String donorId = itemSnapshot.get('donorId'); // Get Donor ID to notify them
        String title = itemSnapshot.get('title');

        // 1. Update Food Item
        transaction.update(itemRef, {
          'quantity': newQuantity,
          'status': newStatus,
        });

        // 2. Create History Record
        DocumentReference claimRef = _db.collection('claims').doc();
        transaction.set(claimRef, {
          'claimId': claimRef.id,
          'itemId': itemId,
          'studentId': studentId,
          'studentName': studentName,
          'claimedAt': FieldValue.serverTimestamp(),
          'title': title,
          'pickupLocation': itemSnapshot.get('pickupLocation'),
          'quantityClaimed': amount,
        });

        // 3. CREATE NOTIFICATION FOR DONOR (New Step)
        DocumentReference notifRef = _db.collection('notifications').doc();
        transaction.set(notifRef, {
          'id': notifRef.id,
          'targetId': donorId, // The Donor receives this
          'title': 'Item Claimed!',
          'body': '$studentName has reserved $amount x $title.',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'claim_alert'
        });
      });

      return null; 
    } catch (e) {
      return e.toString().replaceFirst("Exception: ", "");
    }
  }
}
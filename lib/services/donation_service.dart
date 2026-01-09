import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart'; // Import XFile
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'dart:typed_data';
import '../models/food_item_model.dart';

class DonationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // UPDATED WITH YOUR CREDENTIALS
  final cloudinary = CloudinaryPublic('dkrcpn0sp', 'mysavefood_preset', cache: false);

  // Accepts XFile instead of File
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      CloudinaryResponse response;
      
      if (kIsWeb) {
        // WEB FIX: Read bytes instead of path
        Uint8List bytes = await imageFile.readAsBytes();
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromByteData(
            ByteData.view(bytes.buffer),
            identifier: imageFile.name,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      } else {
        // MOBILE: Use path as before
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
        );
      }
      
      return response.secureUrl; 
    } catch (e) {
      print("Image Upload Error: $e");
      return null;
    }
  }

  Future<void> postFoodItem(FoodItem item) async {
    try {
      await _db.collection('food_items').doc(item.id).set(item.toMap());
    } catch (e) {
      throw e;
    }
  }

  // Method to update the quantity of a food item
  Future<void> updateFoodQuantity(String itemId, int newQuantity) async {
    try {
      // If quantity reaches 0, mark it as claimed. Otherwise, it's available.
      String newStatus = newQuantity <= 0 ? 'claimed' : 'available';
      
      await _db.collection('food_items').doc(itemId).update({
        'quantity': newQuantity,
        'status': newStatus,
      });
    } catch (e) {
      print("Error updating quantity: $e");
      throw e;
    }
  }

  // --- CRITICAL STEP: Creates the History Record ---
  Future<void> createDonationRecord({
    required String foodItemId,
    required String foodTitle,
    required String donorId,
    required String receiverId,
    required int quantity,
  }) async {
    try {
      await _db.collection('donations').add({
        'foodItemId': foodItemId,
        'title': foodTitle,
        'donorId': donorId,
        'receiverId': receiverId,
        'quantity': quantity,
        'status': 'completed', 
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error creating donation record: $e");
      throw e;
    }
  }

  // --- HISTORY SCREEN STREAMS ---

  // Stream for "My Claims"
  Stream<List<Map<String, dynamic>>> getUserClaims(String uid) {
    return _db
        .collection('donations')
        .where('receiverId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // Stream for "My Donations"
  Stream<List<Map<String, dynamic>>> getUserDonations(String uid) {
    return _db
        .collection('donations')
        .where('donorId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }
}
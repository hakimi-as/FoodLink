import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/donation_service.dart';
import '../models/food_item_model.dart';

class DonationProvider with ChangeNotifier {
  final DonationService _service = DonationService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  XFile? _selectedImage;

  bool get isLoading => _isLoading;
  XFile? get selectedImage => _selectedImage;

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      _selectedImage = pickedFile;
      notifyListeners();
    }
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<String?> submitDonation({
    required String donorId,
    required String donorName,
    required String title,
    required String description,
    required int quantity,
    required String location,
    required DateTime expiry,
  }) async {
    if (_selectedImage == null) return "Please select an image.";

    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl = await _service.uploadImage(_selectedImage!);
      if (imageUrl == null) throw "Image upload failed";

      String itemId = DateTime.now().millisecondsSinceEpoch.toString();
      
      FoodItem newItem = FoodItem(
        id: itemId,
        donorId: donorId,
        donorName: donorName,
        title: title,
        description: description,
        quantity: quantity,
        pickupLocation: location,
        imageUrl: imageUrl,
        expiryTime: expiry,
        status: 'available',
        postedTime: DateTime.now(),
      );

      await _service.postFoodItem(newItem);
      
      _isLoading = false;
      clearImage();
      notifyListeners();
      return null; 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> updateFoodQuantity(String itemId, int newQuantity) async {
    if (newQuantity < 0) return;
    try {
      await _service.updateFoodQuantity(itemId, newQuantity);
    } catch (e) {
      rethrow; 
    }
  }

  // --- UPDATED TO MATCH YOUR INDEX NAMES ---
  Future<void> recordClaim({
    required String foodId,
    required String foodTitle,
    required String donorId,
    required String receiverId,
    required int quantityClaimed,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('claims').add({
        'foodId': foodId,
        'foodTitle': foodTitle,       // Matches HistoryScreen reader
        'donorId': donorId,
        'studentId': receiverId,      // MATCHES YOUR INDEX (was receiverId)
        'quantity': quantityClaimed,  // Matches HistoryScreen reader
        'claimedAt': FieldValue.serverTimestamp(), // MATCHES YOUR INDEX (was claimTime)
        'status': 'completed',
      });
    } catch (e) {
      print("Error recording history: $e");
      throw e;
    }
  }
}
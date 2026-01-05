import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/donation_service.dart';
import '../models/food_item_model.dart';

class DonationProvider with ChangeNotifier {
  final DonationService _service = DonationService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  
  // CHANGED: Use XFile instead of File
  XFile? _selectedImage;

  bool get isLoading => _isLoading;
  XFile? get selectedImage => _selectedImage;

  // Pick Image
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      _selectedImage = pickedFile; // Store XFile directly
      notifyListeners();
    }
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // Submit Form
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
      // Pass the XFile directly to the service
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

  // NEW: Call the service to update quantity
  Future<void> updateFoodQuantity(String itemId, int newQuantity) async {
    // Prevent negative quantities
    if (newQuantity < 0) return;

    try {
      await _service.updateFoodQuantity(itemId, newQuantity);
      // No need to notifyListeners() here because the StreamBuilder in the UI 
      // will automatically detect the change in Firestore and rebuild.
    } catch (e) {
      // You can handle errors here if needed (e.g., show a toast or log it)
      rethrow; 
    }
  }
}
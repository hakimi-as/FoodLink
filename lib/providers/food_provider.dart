import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/food_item_model.dart';
import '../services/food_service.dart';
import '../services/storage_service.dart';
import '../core/constants/app_constants.dart';

class FoodProvider extends ChangeNotifier {
  final FoodService _foodService = FoodService();
  final StorageService _storageService = StorageService();

  List<FoodItemModel> _feed = [];
  List<FoodItemModel> _donorItems = [];
  List<FoodItemModel> _allItems = [];
  bool _loading = false;
  String? _error;
  String _searchQuery = '';
  String _activeChip = 'All';

  List<FoodItemModel> get feed => _filteredFeed;
  List<FoodItemModel> get donorItems => _donorItems;
  List<FoodItemModel> get allItems => _allItems;
  bool get loading => _loading;
  String? get error => _error;
  String get activeChip => _activeChip;

  List<FoodItemModel> get _filteredFeed {
    var items = List<FoodItemModel>.from(_feed);
    if (_searchQuery.isNotEmpty) {
      items = items
          .where((i) =>
              i.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              i.pickupLocation
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              i.donorName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    switch (_activeChip) {
      case 'Halal':
        items = items.where((i) => i.isHalal).toList();
        break;
      case 'Expiring Soon':
        items = items.where((i) => i.isUrgent).toList();
        break;
    }
    return items;
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setChip(String chip) {
    _activeChip = chip;
    notifyListeners();
  }

  void listenFeed() {
    _foodService.getAvailableFoods().listen(
      (items) {
        _feed = items;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void listenDonorItems(String donorId) {
    _foodService.getDonorFoods(donorId).listen(
      (items) {
        _donorItems = items;
        notifyListeners();
      },
    );
  }

  void listenAllItems() {
    _foodService.getAllFoods().listen(
      (items) {
        _allItems = items;
        notifyListeners();
      },
    );
  }

  Future<bool> postFood({
    required String donorId,
    required String donorName,
    required String title,
    required String description,
    required String pickupLocation,
    required int quantity,
    required DateTime expiryTime,
    required bool isHalal,
    File? imageFile,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      String imageUrl = '';
      if (imageFile != null) {
        imageUrl =
            await _storageService.uploadFoodImage(imageFile, tempId);
      }
      final item = FoodItemModel(
        itemId: '',
        donorId: donorId,
        donorName: donorName,
        imageUrl: imageUrl,
        title: title,
        description: description,
        quantity: quantity,
        originalQuantity: quantity,
        pickupLocation: pickupLocation,
        expiryTime: expiryTime,
        status: AppConstants.statusAvailable,
        isHalal: isHalal,
        createdAt: DateTime.now(),
      );
      await _foodService.addFoodItem(item);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFoodItem(String itemId) =>
      _foodService.deleteFoodItem(itemId);

  Future<void> updateQuantity(String itemId, int qty) =>
      _foodService.updateQuantity(itemId, qty);
}

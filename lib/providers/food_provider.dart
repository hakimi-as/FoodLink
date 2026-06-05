import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
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

  StreamSubscription<List<FoodItemModel>>? _feedSub;
  StreamSubscription<List<FoodItemModel>>? _donorSub;
  StreamSubscription<List<FoodItemModel>>? _allSub;
  String? _currentDonorId;

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
    _feedSub?.cancel();
    _loading = true;
    notifyListeners();
    _feedSub = _foodService.getAvailableFoods().listen(
      (items) {
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _feed = items;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('[FoodProvider] listenFeed error: $e');
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void listenDonorItems(String donorId) {
    _currentDonorId = donorId;
    _donorSub?.cancel();
    _donorSub = _foodService.getDonorFoods(donorId).listen(
      (items) {
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _donorItems = items;
        notifyListeners();
      },
      onError: (e) => debugPrint('[FoodProvider] listenDonorItems error: $e'),
    );
  }

  void listenAllItems() {
    _allSub?.cancel();
    _allSub = _foodService.getAllFoods().listen(
      (items) {
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _allItems = items;
        notifyListeners();
      },
      onError: (e) => debugPrint('[FoodProvider] listenAllItems error: $e'),
    );
  }

  Future<void> refresh() async {
    final completer = Completer<void>();
    _feedSub?.cancel();
    _loading = true;
    notifyListeners();
    _feedSub = _foodService.getAvailableFoods().listen(
      (items) {
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _feed = items;
        _loading = false;
        _error = null;
        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      },
      onError: (e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future;
  }

  Future<void> refreshDonorItems() async {
    if (_currentDonorId == null) return;
    final completer = Completer<void>();
    _donorSub?.cancel();
    _donorSub = _foodService.getDonorFoods(_currentDonorId!).listen(
      (items) {
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _donorItems = items;
        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      },
      onError: (e) {
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future;
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
    XFile? imageFile,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      String imageUrl = '';
      if (imageFile != null) {
        imageUrl = await _storageService.uploadFoodImage(imageFile, tempId);
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

  @override
  void dispose() {
    _feedSub?.cancel();
    _donorSub?.cancel();
    _allSub?.cancel();
    super.dispose();
  }
}

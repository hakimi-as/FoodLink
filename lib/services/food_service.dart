import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/food_item_model.dart';

class FoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.foodItemsCollection);

  // No orderBy here — combining where+orderBy requires a composite index.
  // Sorting is done client-side in FoodProvider so existing documents work too.
  Stream<List<FoodItemModel>> getAvailableFoods() => _col
      .where('status', isEqualTo: AppConstants.statusAvailable)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => FoodItemModel.fromMap(d.data(), d.id))
          .toList());

  Stream<List<FoodItemModel>> getDonorFoods(String donorId) => _col
      .where('donorId', isEqualTo: donorId)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => FoodItemModel.fromMap(d.data(), d.id))
          .toList());

  Stream<List<FoodItemModel>> getAllFoods() => _col
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => FoodItemModel.fromMap(d.data(), d.id))
          .toList());

  Future<String> addFoodItem(FoodItemModel item) async {
    final ref = _col.doc();
    final withId = FoodItemModel(
      itemId: ref.id,
      donorId: item.donorId,
      donorName: item.donorName,
      imageUrl: item.imageUrl,
      title: item.title,
      description: item.description,
      quantity: item.quantity,
      originalQuantity: item.originalQuantity,
      pickupLocation: item.pickupLocation,
      expiryTime: item.expiryTime,
      status: item.status,
      isHalal: item.isHalal,
      createdAt: item.createdAt,
    );
    await ref.set(withId.toMap());
    return ref.id;
  }

  Future<void> updateQuantity(String itemId, int newQty) => _col.doc(itemId).update({
        'quantity': newQty,
        'status': newQty <= 0
            ? AppConstants.statusClaimed
            : AppConstants.statusAvailable,
      });

  Future<void> deleteFoodItem(String itemId) => _col.doc(itemId).delete();

  Future<FoodItemModel?> getFoodItem(String itemId) async {
    final doc = await _col.doc(itemId).get();
    if (!doc.exists || doc.data() == null) return null;
    return FoodItemModel.fromMap(doc.data()!, doc.id);
  }
}

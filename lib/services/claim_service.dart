import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/claim_model.dart';

class ClaimService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.claimsCollection);

  /// Atomically decrement quantity and create a claim record.
  Future<ClaimModel> claimFood({
    required String itemId,
    required String itemTitle,
    required String donorId,
    required String donorName,
    required String studentId,
    required String studentName,
    required int quantity,
  }) async {
    final claimRef = _col.doc();
    final itemRef = _db
        .collection(AppConstants.foodItemsCollection)
        .doc(itemId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(itemRef);
      if (!snap.exists) throw Exception('Food item not found.');
      final current = (snap.data()!['quantity'] as num).toInt();
      if (current < quantity) throw Exception('Not enough portions available.');
      final newQty = current - quantity;
      tx.update(itemRef, {
        'quantity': newQty,
        'status': newQty <= 0
            ? AppConstants.statusClaimed
            : AppConstants.statusAvailable,
      });
      final claim = ClaimModel(
        claimId: claimRef.id,
        itemId: itemId,
        itemTitle: itemTitle,
        donorId: donorId,
        donorName: donorName,
        studentId: studentId,
        studentName: studentName,
        quantity: quantity,
        timestamp: DateTime.now(),
        status: AppConstants.claimPending,
      );
      tx.set(claimRef, claim.toMap());
    });

    final snap = await claimRef.get();
    return ClaimModel.fromMap(snap.data()!, snap.id);
  }

  Future<void> markClaimCompleted(String claimId) =>
      _col.doc(claimId).update({'status': AppConstants.claimCompleted});

  Stream<List<ClaimModel>> getClaimsForStudent(String studentId) => _col
      .where('studentId', isEqualTo: studentId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => ClaimModel.fromMap(d.data(), d.id)).toList());

  Stream<List<ClaimModel>> getClaimsForDonor(String donorId) => _col
      .where('donorId', isEqualTo: donorId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => ClaimModel.fromMap(d.data(), d.id)).toList());

  Stream<List<ClaimModel>> getClaimsForItem(String itemId) => _col
      .where('itemId', isEqualTo: itemId)
      .snapshots()
      .map((s) => s.docs.map((d) => ClaimModel.fromMap(d.data(), d.id)).toList());

  Stream<List<ClaimModel>> getAllClaims() => _col
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => ClaimModel.fromMap(d.data(), d.id)).toList());
}

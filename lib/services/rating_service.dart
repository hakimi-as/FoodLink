import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

class RatingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('ratings');

  Future<bool> hasRated(String claimId, String studentId) async {
    final snap = await _col
        .where('claimId', isEqualTo: claimId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> submitRating({
    required String donorId,
    required String studentId,
    required String claimId,
    required int stars,
  }) async {
    final ref = _col.doc();
    final rating = RatingModel(
      ratingId: ref.id,
      donorId: donorId,
      studentId: studentId,
      claimId: claimId,
      stars: stars,
      createdAt: DateTime.now(),
    );
    await ref.set(rating.toMap());
    await _updateDonorRating(donorId);
  }

  Future<void> _updateDonorRating(String donorId) async {
    final snap =
        await _col.where('donorId', isEqualTo: donorId).get();
    if (snap.docs.isEmpty) return;
    final total =
        snap.docs.fold<int>(0, (sum, d) => sum + (d['stars'] as num).toInt());
    final count = snap.docs.length;
    final avg = total / count;
    await _db.collection('users').doc(donorId).update({
      'avgRating': avg,
      'ratingCount': count,
    });
  }

  Future<double?> getDonorAverageRating(String donorId) async {
    final snap =
        await _col.where('donorId', isEqualTo: donorId).get();
    if (snap.docs.isEmpty) return null;
    final total =
        snap.docs.fold<int>(0, (sum, d) => sum + (d['stars'] as num).toInt());
    return total / snap.docs.length;
  }
}

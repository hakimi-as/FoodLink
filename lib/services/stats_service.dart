import 'package:cloud_firestore/cloud_firestore.dart';

class StatsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('stats').doc('global');

  Stream<int> listenMealsClaimed() => _doc.snapshots().map(
        (snap) => snap.exists
            ? ((snap.data()?['mealsClaimed'] as num?) ?? 0).toInt()
            : 0,
      );

  Future<void> incrementMealsClaimed(int qty) async {
    try {
      await _doc.set(
        {'mealsClaimed': FieldValue.increment(qty)},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}

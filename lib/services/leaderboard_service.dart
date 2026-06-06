import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class LeaderboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.usersCollection);

  /// Top donors by donorPoints (client-sorted to avoid composite indexes).
  Future<List<UserModel>> topDonors({int limit = 20}) async {
    final snap = await _col.where('role', isEqualTo: AppConstants.roleDonor).get();
    final users = snap.docs.map((d) => UserModel.fromMap(d.data())).toList()
      ..sort((a, b) => b.donorPoints.compareTo(a.donorPoints));
    return users.take(limit).toList();
  }

  /// Top students by studentPoints (client-sorted to avoid composite indexes).
  Future<List<UserModel>> topStudents({int limit = 20}) async {
    final snap = await _col.where('role', isEqualTo: AppConstants.roleStudent).get();
    final users = snap.docs.map((d) => UserModel.fromMap(d.data())).toList()
      ..sort((a, b) => b.studentPoints.compareTo(a.studentPoints));
    return users.take(limit).toList();
  }
}

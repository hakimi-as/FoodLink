import 'package:flutter/foundation.dart';
import '../models/claim_model.dart';
import '../models/user_model.dart';
import '../models/food_item_model.dart';
import '../services/claim_service.dart';

class ClaimProvider extends ChangeNotifier {
  final ClaimService _service = ClaimService();

  List<ClaimModel> _myClaims = [];
  List<ClaimModel> _donorClaims = [];
  List<ClaimModel> _allClaims = [];
  bool _loading = false;
  String? _error;

  List<ClaimModel> get myClaims => _myClaims;
  List<ClaimModel> get donorClaims => _donorClaims;
  List<ClaimModel> get allClaims => _allClaims;
  bool get loading => _loading;
  String? get error => _error;

  void listenMyClaims(String studentId) {
    _service.getClaimsForStudent(studentId).listen((c) {
      c.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _myClaims = c;
      notifyListeners();
    });
  }

  void listenDonorClaims(String donorId) {
    _service.getClaimsForDonor(donorId).listen((c) {
      c.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _donorClaims = c;
      notifyListeners();
    });
  }

  void listenAllClaims() {
    _service.getAllClaims().listen((c) {
      c.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _allClaims = c;
      notifyListeners();
    });
  }

  Future<ClaimModel?> claimFood({
    required FoodItemModel item,
    required UserModel student,
    required int quantity,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final claim = await _service.claimFood(
        itemId: item.itemId,
        itemTitle: item.title,
        donorId: item.donorId,
        donorName: item.donorName,
        studentId: student.uid,
        studentName: student.name,
        quantity: quantity,
      );
      return claim;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markCompleted(String claimId) =>
      _service.markClaimCompleted(claimId);
}

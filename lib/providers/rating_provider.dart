import 'package:flutter/foundation.dart';
import '../services/rating_service.dart';

class RatingProvider extends ChangeNotifier {
  final RatingService _service = RatingService();

  final Map<String, double> _donorRatings = {};
  final Set<String> _loadingDonors = {};
  final Set<String> _ratedClaims = {};

  double? getDonorRating(String donorId) => _donorRatings[donorId];

  void fetchDonorRating(String donorId) {
    if (_donorRatings.containsKey(donorId)) return;
    if (_loadingDonors.contains(donorId)) return;
    _loadingDonors.add(donorId);
    _service.getDonorAverageRating(donorId).then((rating) {
      _loadingDonors.remove(donorId);
      if (rating != null) {
        _donorRatings[donorId] = rating;
        notifyListeners();
      }
    }).catchError((e) {
      _loadingDonors.remove(donorId);
      debugPrint('[RatingProvider] fetchDonorRating error: $e');
    });
  }

  Future<bool> hasRated(String claimId, String studentId) async {
    if (_ratedClaims.contains(claimId)) return true;
    final result = await _service.hasRated(claimId, studentId);
    if (result) _ratedClaims.add(claimId);
    return result;
  }

  Future<bool> submitRating({
    required String donorId,
    required String studentId,
    required String claimId,
    required int stars,
  }) async {
    try {
      await _service.submitRating(
        donorId: donorId,
        studentId: studentId,
        claimId: claimId,
        stars: stars,
      );
      _ratedClaims.add(claimId);
      // Refresh donor rating
      _donorRatings.remove(donorId);
      fetchDonorRating(donorId);
      return true;
    } catch (e) {
      debugPrint('[RatingProvider] submitRating error: $e');
      return false;
    }
  }
}

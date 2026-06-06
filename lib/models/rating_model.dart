import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String ratingId;
  final String donorId;
  final String studentId;
  final String claimId;
  final int stars;
  final DateTime createdAt;

  const RatingModel({
    required this.ratingId,
    required this.donorId,
    required this.studentId,
    required this.claimId,
    required this.stars,
    required this.createdAt,
  });

  factory RatingModel.fromMap(Map<String, dynamic> map, String id) =>
      RatingModel(
        ratingId: id,
        donorId: map['donorId'] as String,
        studentId: map['studentId'] as String,
        claimId: map['claimId'] as String,
        stars: (map['stars'] as num).toInt(),
        createdAt: map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'donorId': donorId,
        'studentId': studentId,
        'claimId': claimId,
        'stars': stars,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? photoUrl;
  final double? avgRating;
  final int ratingCount;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.avgRating,
    this.ratingCount = 0,
    required this.createdAt,
  });

  bool get isDonor => role == AppConstants.roleDonor;
  bool get isStudent => role == AppConstants.roleStudent;
  bool get isAdmin => role == AppConstants.roleAdmin;

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        phone: (map['phone'] as String?) ?? '',
        role: map['role'] as String,
        photoUrl: map['photoUrl'] as String?,
        avgRating: (map['avgRating'] as num?)?.toDouble(),
        ratingCount: (map['ratingCount'] as num?)?.toInt() ?? 0,
        createdAt: map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'photoUrl': photoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    double? avgRating,
    int? ratingCount,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        role: role,
        photoUrl: photoUrl ?? this.photoUrl,
        avgRating: avgRating ?? this.avgRating,
        ratingCount: ratingCount ?? this.ratingCount,
        createdAt: createdAt,
      );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class FoodItemModel {
  final String itemId;
  final String donorId;
  final String donorName;
  final String imageUrl;
  final String title;
  final String description;
  final int quantity;
  final int originalQuantity;
  final String pickupLocation;
  final DateTime expiryTime;
  final String status;
  final bool isHalal;
  final DateTime createdAt;

  const FoodItemModel({
    required this.itemId,
    required this.donorId,
    required this.donorName,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.quantity,
    required this.originalQuantity,
    required this.pickupLocation,
    required this.expiryTime,
    required this.status,
    required this.isHalal,
    required this.createdAt,
  });

  bool get isAvailable => status == AppConstants.statusAvailable && quantity > 0;
  bool get isExpired => DateTime.now().isAfter(expiryTime);
  bool get isUrgent {
    final diff = expiryTime.difference(DateTime.now());
    return diff.inHours <= 1 && diff.isNegative == false;
  }

  String get timeRemaining {
    final diff = expiryTime.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours >= 1) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    return '${diff.inMinutes}m';
  }

  String get postedAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  factory FoodItemModel.fromMap(Map<String, dynamic> map, String id) =>
      FoodItemModel(
        itemId: id,
        donorId: map['donorId'] as String,
        donorName: (map['donorName'] as String?) ?? '',
        imageUrl: (map['imageUrl'] as String?) ?? '',
        title: map['title'] as String,
        description: (map['description'] as String?) ?? '',
        quantity: (map['quantity'] as num).toInt(),
        originalQuantity: (map['originalQuantity'] as num?)?.toInt() ??
            (map['quantity'] as num).toInt(),
        pickupLocation: (map['pickupLocation'] as String?) ?? '',
        expiryTime: map['expiryTime'] is Timestamp
            ? (map['expiryTime'] as Timestamp).toDate()
            : DateTime.now().add(const Duration(hours: 4)),
        status: (map['status'] as String?) ?? AppConstants.statusAvailable,
        isHalal: (map['isHalal'] as bool?) ?? false,
        createdAt: map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'donorId': donorId,
        'donorName': donorName,
        'imageUrl': imageUrl,
        'title': title,
        'description': description,
        'quantity': quantity,
        'originalQuantity': originalQuantity,
        'pickupLocation': pickupLocation,
        'expiryTime': Timestamp.fromDate(expiryTime),
        'status': status,
        'isHalal': isHalal,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  FoodItemModel copyWith({int? quantity, String? status}) => FoodItemModel(
        itemId: itemId,
        donorId: donorId,
        donorName: donorName,
        imageUrl: imageUrl,
        title: title,
        description: description,
        quantity: quantity ?? this.quantity,
        originalQuantity: originalQuantity,
        pickupLocation: pickupLocation,
        expiryTime: expiryTime,
        status: status ?? this.status,
        isHalal: isHalal,
        createdAt: createdAt,
      );
}

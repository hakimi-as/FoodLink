import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String donorId;
  final String donorName; // Store name for easier display
  final String title;
  final String description;
  final int quantity;
  final String pickupLocation;
  final String imageUrl;
  final DateTime expiryTime; // Best Before
  final String status; // 'available' or 'claimed'
  final DateTime postedTime;

  FoodItem({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.title,
    required this.description,
    required this.quantity,
    required this.pickupLocation,
    required this.imageUrl,
    required this.expiryTime,
    required this.status,
    required this.postedTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donorId': donorId,
      'donorName': donorName,
      'title': title,
      'description': description,
      'quantity': quantity,
      'pickupLocation': pickupLocation,
      'imageUrl': imageUrl,
      'expiryTime': Timestamp.fromDate(expiryTime),
      'status': status,
      'postedTime': Timestamp.fromDate(postedTime),
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      donorId: map['donorId'] ?? '',
      donorName: map['donorName'] ?? 'Unknown Donor',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 0,
      pickupLocation: map['pickupLocation'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      expiryTime: (map['expiryTime'] as Timestamp).toDate(),
      status: map['status'] ?? 'available',
      postedTime: (map['postedTime'] as Timestamp).toDate(),
    );
  }
}
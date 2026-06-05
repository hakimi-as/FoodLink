import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class ClaimModel {
  final String claimId;
  final String itemId;
  final String itemTitle;
  final String donorId;
  final String donorName;
  final String studentId;
  final String studentName;
  final int quantity;
  final DateTime timestamp;
  final String status;

  const ClaimModel({
    required this.claimId,
    required this.itemId,
    required this.itemTitle,
    required this.donorId,
    required this.donorName,
    required this.studentId,
    required this.studentName,
    required this.quantity,
    required this.timestamp,
    required this.status,
  });

  bool get isPending => status == AppConstants.claimPending;
  bool get isCompleted => status == AppConstants.claimCompleted;

  factory ClaimModel.fromMap(Map<String, dynamic> map, String id) => ClaimModel(
        claimId: id,
        itemId: map['itemId'] as String,
        itemTitle: (map['itemTitle'] as String?) ?? '',
        donorId: (map['donorId'] as String?) ?? '',
        donorName: (map['donorName'] as String?) ?? '',
        studentId: map['studentId'] as String,
        studentName: (map['studentName'] as String?) ?? '',
        quantity: (map['quantity'] as num).toInt(),
        timestamp: map['timestamp'] is Timestamp
            ? (map['timestamp'] as Timestamp).toDate()
            : DateTime.now(),
        status: (map['status'] as String?) ?? AppConstants.claimPending,
      );

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'itemTitle': itemTitle,
        'donorId': donorId,
        'donorName': donorName,
        'studentId': studentId,
        'studentName': studentName,
        'quantity': quantity,
        'timestamp': Timestamp.fromDate(timestamp),
        'status': status,
      };

  ClaimModel copyWith({String? status}) => ClaimModel(
        claimId: claimId,
        itemId: itemId,
        itemTitle: itemTitle,
        donorId: donorId,
        donorName: donorName,
        studentId: studentId,
        studentName: studentName,
        quantity: quantity,
        timestamp: timestamp,
        status: status ?? this.status,
      );
}

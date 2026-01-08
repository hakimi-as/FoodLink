class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  // NEW FIELDS
  final String? phone;
  final String? bio;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.bio,
    this.photoUrl,
  });

  // Convert from Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      phone: map['phone'],       // Read new field
      bio: map['bio'],           // Read new field
      photoUrl: map['photoUrl'], // Read new field
    );
  }

  // Convert to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'bio': bio,
      'photoUrl': photoUrl,
    };
  }
}
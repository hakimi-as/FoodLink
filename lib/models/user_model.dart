class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'donor' or 'student'

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  // Convert Firestore document to User Object
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
    );
  }

  // Convert User Object to Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
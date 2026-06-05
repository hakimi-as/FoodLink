class AppConstants {
  AppConstants._();

  static const String appName = 'FoodLink';
  static const String tagline = 'Connecting Surplus. Feeding Communities.';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String foodItemsCollection = 'food_items';
  static const String claimsCollection = 'claims';

  // User roles
  static const String roleDonor = 'donor';
  static const String roleStudent = 'student';
  static const String roleAdmin = 'admin';

  // Food item status
  static const String statusAvailable = 'available';
  static const String statusClaimed = 'claimed';
  static const String statusExpired = 'expired';

  // Claim status
  static const String claimPending = 'pending';
  static const String claimCompleted = 'completed';
  static const String claimCancelled = 'cancelled';

  // SharedPreferences keys
  static const String prefThemeMode = 'theme_mode';
}

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? v) {
    _error = v;
    notifyListeners();
  }

  void clearError() => _setError(null);

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _service.signInWithEmail(email, password);
      notifyListeners();
      NotificationService.instance.saveTokenToFirestore(_user!.uid);
      return true;
    } catch (e) {
      _setError(_friendlyError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _service.registerWithEmail(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      notifyListeners();
      NotificationService.instance.saveTokenToFirestore(_user!.uid);
      return true;
    } catch (e) {
      _setError(_friendlyError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _service.signInWithGoogle();
      notifyListeners();
      NotificationService.instance.saveTokenToFirestore(_user!.uid);
      return true;
    } catch (e) {
      final msg = e.toString();
      // User deliberately closed the popup — not an error worth surfacing
      if (msg.contains('popup_closed') || msg.contains('popup-closed-by-user')) {
        return false;
      }
      _setError(_friendlyError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) =>
      _service.sendPasswordResetEmail(email);

  void updateUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  Future<bool> updateProfile({required String name, required String phone}) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      await _service.updateUserProfile(_user!.uid, name: name, phone: phone);
      _user = _user!.copyWith(name: name, phone: phone);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_friendlyError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePhoto(String photoUrl) async {
    if (_user == null) return false;
    try {
      await _service.updateUserPhoto(_user!.uid, photoUrl);
      _user = _user!.copyWith(photoUrl: photoUrl);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AuthProvider] updatePhoto error: $e');
      return false;
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('user-not-found')) return 'No account found with this email.';
    if (msg.contains('wrong-password') || msg.contains('invalid-credential')) return 'Incorrect email or password.';
    if (msg.contains('email-already-in-use')) return 'This email is already registered.';
    if (msg.contains('weak-password')) return 'Password is too weak (min 6 chars).';
    if (msg.contains('invalid-email')) return 'Please enter a valid email address.';
    if (msg.contains('operation-not-allowed')) return 'Email sign-in is not enabled. Contact support.';
    if (msg.contains('network-request-failed')) return 'No internet connection. Please try again.';
    if (msg.contains('too-many-requests')) return 'Too many attempts. Please wait and try again.';
    if (msg.contains('cancelled')) return 'Sign-in was cancelled.';
    // Surface the raw Firebase error code during development so it's not swallowed
    debugPrint('[AuthProvider] Unhandled error: $e');
    return 'Something went wrong. Please try again.';
  }
}

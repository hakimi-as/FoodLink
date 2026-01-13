import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get currentUserModel => _user;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  // --- NEW: Manually set user (For Role Selection Screen) ---
  void setCurrentUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  // --- LOGIN ---
  Future<String?> login(String email, String password) async {
    _setLoading(true);
    try {
      User? firebaseUser = await _authService.login(email, password);

      if (firebaseUser != null) {
        _user = await _authService.getUserDetails(firebaseUser.uid);
      }

      _setLoading(false);
      return null;
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  // --- REGISTER ---
  Future<String?> register(String email, String password, String name,
      String role, String phone) async {
    _setLoading(true);
    try {
      _user = await _authService.register(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
      );
      _setLoading(false);
      return null;
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  // --- UPDATE USER ---
  Future<String?> updateUser(UserModel updatedUser) async {
    _setLoading(true);
    try {
      await _authService.updateUser(updatedUser);
      _user = updatedUser;
      _setLoading(false);
      notifyListeners();
      return null;
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
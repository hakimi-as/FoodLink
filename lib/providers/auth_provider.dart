import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUserModel;
  bool _isLoading = false;

  UserModel? get currentUserModel => _currentUserModel;
  bool get isLoading => _isLoading;

  // Register
  Future<String?> register(String email, String password, String name, String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUserModel = await _authService.register(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return null; // No error
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // Login
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      User? user = await _authService.login(email, password);
      if (user != null) {
        // Fetch role data from Firestore
        _currentUserModel = await _authService.getUserDetails(user.uid);
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  void logout() {
    _authService.signOut();
    _currentUserModel = null;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  // Login Action
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // API call simulation delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock user login data setting
      _user = UserModel(
        id: 'usr_101',
        name: 'M. Shafqat',
        email: email,
      );

      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Login Error: $e');
      return false;
    }
  }

  // Logout Action
  void logout() {
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
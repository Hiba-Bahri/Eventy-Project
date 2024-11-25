import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventy/core/services/firebase_auth_services.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? _user;
  bool _isLoggedIn = false;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      _user = _authService.getCurrentUser();
    }

    notifyListeners();
  }

  Future<User?> login(String email, String password) async {
    try {
      final User? user =
          await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        _user = user;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        _isLoggedIn = true;
        notifyListeners();
      }
      return user;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  Future<User?> register(String email, String password, String username) async {
    try {
      final User? user = await _authService.signUpWithEmailAndPassword(
          email, password, username);
      if (user != null) {
        _user = user;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        _isLoggedIn = true;
        notifyListeners();
      }
      return user;
    } catch (e) {
      throw Exception("Registration failed: $e");
    }
  }

Future<bool> logout() async {
  try {
    await _authService.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    _user = null;
    _isLoggedIn = false;

    notifyListeners();
    return true;
  } catch (e) {
    throw Exception("Logout failed: $e");
  }
}

}

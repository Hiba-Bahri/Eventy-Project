import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventy/core/services/firebase_auth_services.dart';
import 'package:eventy/data/models/User.dart' as UserModel;

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? _user;
  UserModel.User? _fetchedUser;
  bool _isLoggedIn = false;

  AuthProvider() {
    loadUserFromPrefs();
  }

  User? get user => _user;

  bool get isLoggedIn => _isLoggedIn;
  UserModel.User? get fetchedUser => _fetchedUser;

  Future<User?> getCurrentUser() async {
    try {
      final User? user = await _authService.getCurrentUser();
      if (user != null) {
        _user = user;

        notifyListeners();
      }

      return user;
    } catch (e) {
      throw Exception("Fetch failed: $e");
    }
  }

  final Map<String, UserModel.User> _userCache = {};

  Future<UserModel.User?> getUserData(String uid) async {
    if (_userCache.containsKey(uid)) {
      return _userCache[uid];
    }
    try {
      final UserModel.User? user = await _authService.getUserData(uid);
      if (user != null) {
        _userCache[uid] = user;
        _fetchedUser = user;
        notifyListeners();
      }
      return user;
    } catch (e) {
      throw Exception("Failed to fetch user data: $e");
    }
  }

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      _user = _authService.getCurrentUser();
      print("CONNECTED USER: $_user");
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
        print(user);
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

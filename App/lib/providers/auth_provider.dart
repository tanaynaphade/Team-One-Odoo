// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String _error = '';

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null && _token != null;
  String get error => _error;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        _token = token;
        final user = await ApiService.getCurrentUser(token);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
        } else {
          // Token is invalid, clear it
          await _clearAuthData();
        }
      }
    } catch (e) {
      print('Error loading user from preferences: \$e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await ApiService.login(email, password);

      if (result['success']) {
        _token = result['data']['token'];
        _currentUser = User.fromJson(result['data']['user']);

        // Save to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: \$e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      List<String> nameParts = name.split(' ');
      final result = await ApiService.register(nameParts[0],nameParts[1], email, password);

      if (result['success'] == true) {
        final data = result['data'];
          return true;
      } else {
        _error = result['error'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Registration error: $e');
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    if (_token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await ApiService.updateUserProfile(_token!, userData);

      if (success) {
        // Refresh user data
        final updatedUser = await ApiService.getCurrentUser(_token!);
        if (updatedUser != null) {
          _currentUser = updatedUser;
        }
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
    notifyListeners();
  }

  Future<void> _clearAuthData() async {
    _currentUser = null;
    _token = null;
    _error = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}

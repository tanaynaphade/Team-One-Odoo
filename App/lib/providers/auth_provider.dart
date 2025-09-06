// lib/providers/auth_provider.dart
import 'dart:convert';
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
      final userDataString = prefs.getString('user_data');

      if (token != null && userDataString != null) {
        _token = token;

        // Try to load user from stored data first
        try {
          final userData = jsonDecode(userDataString);
          _currentUser = User.fromJson(userData);
          notifyListeners();
        } catch (e) {
          print('Error parsing stored user data: $e');
          // If stored data is invalid, try to fetch from server
          final user = await ApiService.getCurrentUser(token);
          if (user != null) {
            _currentUser = user;
            // Save the fresh user data
            await prefs.setString('user_data', jsonEncode(user.toJson()));
            notifyListeners();
          } else {
            // Token is invalid, clear it
            await _clearAuthData();
          }
        }
      }
    } catch (e) {
      print('Error loading user from preferences: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await ApiService.login(email, password);

      // Debug prints
      print('Login result: $result');
      print('Success: ${result['success']}');
      print('Data: ${result['data']}');

      if (result['success']) {
        final data = result['data'];

        // Debug the data structure
        print('Data keys: ${data.keys.toList()}');
        print('Token: ${data['token']}');
        print('User data: ${data['user']}');

        // Check if token exists
        if (data['token'] != null) {
          _token = data['token'];
          print('Token set successfully: $_token');
        } else {
          print('Token is null!');
          _error = 'No token received from server';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Check if user data exists
        if (data['user'] != null) {
          try {
            _currentUser = User.fromJson(data['user']);
            print('User created successfully: ${_currentUser?.email}');
          } catch (e) {
            print('Error creating user from JSON: $e');
            print('User data received: ${data['user']}');
            _error = 'Failed to parse user data: $e';
            _isLoading = false;
            notifyListeners();
            return false;
          }
        } else {
          print('User data is null!');
          _error = 'No user data received from server';
          _isLoading = false;
          notifyListeners();
          return false;
        }

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
      print('Login exception: $e');
      _error = 'Login failed: $e';
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
      List<String> nameParts = name.trim().split(' ');
      String firstName = nameParts[0];
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final result = await ApiService.register(firstName, lastName, email, password);

      if (result['success'] == true) {
        _isLoading = false;
        notifyListeners();
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
          // Update stored user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));
        }
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('Update profile error: $e');
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
    await prefs.remove('user_data');
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
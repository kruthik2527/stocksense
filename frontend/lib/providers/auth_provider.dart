import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _user;
  bool _isLoading = true;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final token = await _authService.getToken();
    if (token != null) {
      _user = await _authService.getSavedUser();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      final data = await _authService.login(email: email, password: password);
      if (data['success'] == true) {
        _user = AppUser.fromJson(data['user']);
        notifyListeners();
        return null; // no error
      }
      return data['message'] ?? 'Login failed';
    } on TimeoutException {
      return 'Request timed out. Check that the backend is running and reachable.';
    } catch (e) {
      return 'Could not reach server: $e';
    }
  }

  Future<String?> signup(String name, String email, String password, String role) async {
    try {
      final data = await _authService.signup(name: name, email: email, password: password, role: role);
      if (data['success'] == true) {
        _user = AppUser.fromJson(data['user']);
        notifyListeners();
        return null;
      }
      return data['message'] ?? 'Signup failed';
    } on TimeoutException {
      return 'Request timed out. Check that the backend is running and reachable.';
    } catch (e) {
      return 'Could not reach server: $e';
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
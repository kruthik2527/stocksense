import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static const _tokenKey = 'stocksense_token';
  static const _userKey = 'stocksense_user';
  static const _timeout = Duration(seconds: 15);

  // Safely decode a response body. If the server returns something that
  // isn't valid JSON (HTML error page, empty body, etc.) this throws a
  // clear exception instead of letting jsonDecode's error bubble up unhandled.
  Map<String, dynamic> _decode(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw Exception('Unexpected response format from server');
    } catch (_) {
      throw Exception('Server returned an invalid response (status ${res.statusCode})');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  Future<AppUser?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    return AppUser.fromJson(jsonDecode(userStr));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String role = 'warehouse_staff',
  }) async {
    final res = await http
        .post(
          Uri.parse('${ApiConfig.auth}/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
        )
        .timeout(_timeout);
    final data = _decode(res);
    if (res.statusCode == 201 && data['success'] == true) {
      await _saveSession(data['token'], data['user']);
    }
    return data;
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final res = await http
        .post(
          Uri.parse('${ApiConfig.auth}/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);
    final data = _decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      await _saveSession(data['token'], data['user']);
    }
    return data;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await http
        .post(
          Uri.parse('${ApiConfig.auth}/forgot-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        )
        .timeout(_timeout);
    return _decode(res);
  }

  Future<Map<String, dynamic>> verifyOtp({required String email, required String otp}) async {
    final res = await http
        .post(
          Uri.parse('${ApiConfig.auth}/verify-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'otp': otp}),
        )
        .timeout(_timeout);
    return _decode(res);
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final res = await http
        .post(
          Uri.parse('${ApiConfig.auth}/reset-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'otp': otp, 'newPassword': newPassword}),
        )
        .timeout(_timeout);
    return _decode(res);
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String url) async {
    final res = await http.get(Uri.parse(url), headers: await _headers());
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse(url), headers: await _headers(), body: jsonEncode(body));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> put(String url, Map<String, dynamic> body) async {
    final res = await http.put(Uri.parse(url), headers: await _headers(), body: jsonEncode(body));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> patch(String url, [Map<String, dynamic>? body]) async {
    final res = await http.patch(Uri.parse(url), headers: await _headers(), body: jsonEncode(body ?? {}));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> delete(String url) async {
    final res = await http.delete(Uri.parse(url), headers: await _headers());
    return jsonDecode(res.body);
  }
}

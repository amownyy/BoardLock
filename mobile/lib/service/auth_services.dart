import 'dart:convert';
import 'package:BoardLock/constant/config.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>?> validateToken(String token) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/token/validate/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    final data = jsonDecode(response.body);
    return data['status'] == true ? data['user'] : null;
  }

  static Future<Map<String, dynamic>?> login(
    String phone,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    final data = jsonDecode(response.body);
    return data['status'] == true ? data : null;
  }
}

import 'dart:convert';
import 'package:BoardLock/constant/config.dart';
import 'package:http/http.dart' as http;

class SchoolService {
  static Future<Map<String, dynamic>?> getSchool(String schoolId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/school/$schoolId'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    return data['status'] == true ? data['data'] : null;
  }
}

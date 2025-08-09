import 'dart:convert';
import 'package:BoardLock/constant/config.dart';
import 'package:http/http.dart' as http;

class BoardService {
  static Future<List<Map<String, dynamic>>> getBoards(String schoolId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/board/$schoolId'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    if (data['status'] == true && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    return [];
  }

  static Future<bool> unlockBoard(String schoolId, String boardName) async {
    return _sendAction(schoolId, boardName, "unlock");
  }

  static Future<bool> lockBoard(String schoolId, String boardName) async {
    return _sendAction(schoolId, boardName, "lock");
  }

  static Future<bool> shutdownBoard(String schoolId, String boardName) async {
    return _sendAction(schoolId, boardName, "shutdown");
  }

  static Future<bool> restartBoard(String schoolId, String boardName) async {
    return _sendAction(schoolId, boardName, "restart");
  }

  static Future<bool> _sendAction(
    String schoolId,
    String boardName,
    String action,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/board/$schoolId/$boardName/$action',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    final data = jsonDecode(response.body);
    return data['status'] == true;
  }
}

import 'dart:convert';
import 'package:app/constant/config.dart';
import 'package:app/model/board_model.dart';
import 'package:app/model/school_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<School>> fetchSchools() async {
    final response = await http.get(Uri.parse(ApiConfig.getSchoolsUrl));
    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      return (data['data'] as List).map((e) => School.fromJson(e)).toList();
    }
    throw Exception("Okullar alınamadı.");
  }

  static Future<List<Board>> fetchBoards(String schoolId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.getBoardsUrl(schoolId)),
    );
    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      return (data['data'] as List).map((e) => Board.fromJson(e)).toList();
    }
    throw Exception("Tahtalar alınamadı.");
  }

  static Future<String?> fetchLatestVersion() async {
    final url = Uri.parse("${ApiConfig.getUpdateUrl}/latest");
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      return data['data']['version'];
    }
    return null;
  }

  static Future<String?> fetchBoardStatus(
    String schoolId,
    String boardId,
  ) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/board/$schoolId/$boardId");
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      return data['data']['status'];
    }
    return null;
  }

  static void setBoardActive(String schoolId, String boardId) async {
    final url = Uri.parse(ApiConfig.setBoardActiveUrl(schoolId, boardId));
    await http.post(url);
  }

  static Future<bool> shutDownBoard(String schoolId, String boardId) async {
    final response = await http.post(
      Uri.parse(ApiConfig.shutDownBoardUrl(schoolId, boardId)),
    );
    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      return true;
    }
    throw Exception("Tahta kapatılamadı.");
  }

  static Future<bool> restartBoard(String schoolId, String boardId) async {
    final response = await http.post(
      Uri.parse(ApiConfig.restartBoardUrl(schoolId, boardId)),
    );
    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      return true;
    }
    throw Exception("Tahta yeniden başlatılamadı.");
  }
}

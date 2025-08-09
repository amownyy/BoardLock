import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveSelections(
    String schoolId,
    String schoolName,
    String boardId,
    String version,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('schoolId', schoolId);
    await prefs.setString('schoolName', schoolName);
    await prefs.setString('boardId', boardId);
    await prefs.setString('version', version);
  }

  static Future<Map<String, String?>> loadSelections() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'schoolId': prefs.getString('schoolId'),
      'schoolName': prefs.getString('schoolName'),
      'boardId': prefs.getString('boardId'),
      'version': prefs.getString('version'),
    };
  }
}

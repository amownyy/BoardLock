import 'dart:convert';
import 'dart:io';
import 'package:app/constant/config.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

class UpdateService {
  static Future<void> checkForUpdates(String currentVersion) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.getUpdateUrl}/latest"),
    );
    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      final latestVersion = data['data']['version'];
      final zipUrl = data['data']['url'];

      if (latestVersion != currentVersion) {
        await _downloadAndInstall(zipUrl);
      }
    }
  }

  static Future<void> _downloadAndInstall(String zipUrl) async {
    final tempDir = await getTemporaryDirectory();
    final zipPath = "${tempDir.path}/update.zip";

    final response = await http.get(Uri.parse(zipUrl));
    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(response.bodyBytes);

    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    final appDir = Directory.current.path;
    for (final file in archive) {
      final filePath = '$appDir/${file.name}';
      if (file.isFile) {
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      }
    }
  }
}

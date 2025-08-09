import 'dart:io';

import 'package:app/page/lock_page.dart';
import 'package:app/page/setup_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    WindowOptions options = const WindowOptions(
      fullScreen: true,
      skipTaskbar: false,
    );

    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setFullScreen(true);
      await windowManager.show();
      await windowManager.focus();
    });
  }
  final prefs = await SharedPreferences.getInstance();
  final schoolId = prefs.getString('schoolId');
  final boardId = prefs.getString('boardId');

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akıllı Tahta Kilidi',
      theme: ThemeData.dark(),
      home: (schoolId != null && boardId != null)
          ? const LockScreen()
          : const SetupScreen(),
    ),
  );
}

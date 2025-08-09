import 'dart:io';

import 'package:app/service/api_service.dart';
import 'package:app/service/storage_service.dart';
import 'package:app/service/update_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'dart:io' as io;

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String schoolId = "";
  String schoolName = "";
  String boardId = "";
  String qrData = "";
  String announcement = "";
  String currentVersion = "1.0.0";
  String _networkStatus = "Bağlı Değil";

  bool isLocked = true;
  bool _showClock = false;
  DateTime _now = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    loadPrefs();
    _checkConnection();
    killExplorer();
    listenBoardStatus();
    UpdateService.checkForUpdates(currentVersion);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> loadPrefs() async {
    final data = await StorageService.loadSelections();
    setState(() {
      schoolId = data['schoolId'] ?? "";
      schoolName = data['schoolName'] ?? "";
      boardId = data['boardId'] ?? "";
      qrData =
          "${data['schoolName'] ?? ""}-${data['schoolId'] ?? ""}-${data['boardId'] ?? ""}";
      currentVersion = data['version'] ?? "";
    });
    setBoardActive();
  }

  Future<void> _checkConnection() async {
    try {
      final result = await io.InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() => _networkStatus = "Bağlı");
      }
    } catch (_) {
      setState(() => _networkStatus = "Bağlı Değil");
    }
  }

  void setBoardActive() {
    ApiService.setBoardActive(schoolId, boardId);
  }

  void restartSystem() {
    ApiService.restartBoard(schoolId, boardId);
    io.Process.run("shutdown", ["/r", "/t", "0"]);
  }

  void shutdownSystem() {
    ApiService.shutDownBoard(schoolId, boardId);
    io.Process.run("shutdown", ["/s", "/t", "0"]);
  }

  void killExplorer() {
    Timer.periodic(const Duration(seconds: 3), (_) {
      if (Platform.isWindows) {
        io.Process.run("taskkill", ["/f", "/im", "explorer.exe"]);
        io.Process.run("taskkill", ["/f", "/im", "cmd.exe"]);
      }
    });
  }

  void listenBoardStatus() {
    Timer.periodic(const Duration(seconds: 3), (_) async {
      final status = await ApiService.fetchBoardStatus(schoolId, boardId);
      if (status == "Aktif") {
        if (isLocked) {
          setState(() => isLocked = false);
        }
      } else if (status == "Kilitli") {
        if (!isLocked) {
          setState(() => isLocked = true);
        }
      } else if (status == "Kapalı") {
        shutdownSystem();
      } else if (status == "Yeniden Başlatılıyor") {
        restartSystem();
      }
    });
  }

  String formatTime(DateTime time) =>
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";

  String formatDate(DateTime date) => "${date.day}.${date.month}.${date.year}";

  @override
  Widget build(BuildContext context) {
    if (_showClock) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatTime(_now),
                style: const TextStyle(fontSize: 100, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                formatDate(_now),
                style: const TextStyle(fontSize: 24, color: Colors.white54),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white10,
          onPressed: () => setState(() => _showClock = false),
          child: const Icon(Icons.close, color: Colors.white),
        ),
      );
    }

    return WillPopScope(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 80,
                left: 80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                right: 80,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 300,
                left: MediaQuery.of(context).size.width / 2 - 300,
                child: Container(
                  width: 600,
                  height: 600,
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // İçerik
              SafeArea(
                child: Column(
                  children: [
                    // Üst bilgi barı
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.wifi,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _networkStatus,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formatTime(_now),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Column(
                      children: [
                        Text(
                          formatDate(_now),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          schoolName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 4,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.cyan],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: QrImageView(
                                  data: qrData,
                                  size: 180,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Colors.black,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.circle,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Kilidi açmak için QR kodu tarayın",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                "Mobil uygulamanızla bu kodu okutun",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    if (announcement.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Duyuru",
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    announcement,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: restartSystem,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            "Yeniden Başlat",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF009688,
                            ).withOpacity(0.2),
                            foregroundColor: Colors.tealAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 6,
                          ),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton.icon(
                          onPressed: shutdownSystem,
                          icon: const Icon(
                            Icons.power_settings_new,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Kapat",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFF44336,
                            ).withOpacity(0.2),
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 6,
                          ),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _showClock = true),
                          icon: const Icon(Icons.schedule, color: Colors.white),
                          label: const Text(
                            "Saat",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.withOpacity(0.2),
                            foregroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Resar Software Solutions © ${DateTime.now().year}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async => false,
    );
  }
}

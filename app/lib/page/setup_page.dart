import 'dart:io';

import 'package:app/model/board_model.dart';
import 'package:app/model/school_model.dart';
import 'package:app/service/api_service.dart';
import 'package:app/service/storage_service.dart';
import 'package:flutter/material.dart';

import 'lock_page.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  List<School> schools = [];
  List<Board> boards = [];

  int? selectedSchoolId;
  String? selectedBoardName;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadSchools();
  }

  Future<void> loadSchools() async {
    setState(() => isLoading = true);
    try {
      schools = await ApiService.fetchSchools();
    } catch (e) {
      showError("Okullar yüklenemedi");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadBoards(String schoolId) async {
    setState(() {
      boards.clear();
      selectedBoardName = null;
      isLoading = true;
    });
    try {
      boards = await ApiService.fetchBoards(schoolId);
    } catch (e) {
      showError("Tahtalar yüklenemedi");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void registerAutoStartTask() {
    if (Platform.isWindows) {
      Process.run("powershell", [
        "-Command",
        '''
        \$action = New-ScheduledTaskAction -Execute "${Platform.resolvedExecutable.replaceAll('\\', '\\\\')}"
        \$trigger = New-ScheduledTaskTrigger -AtLogOn
        \$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\\\\SYSTEM" -RunLevel Highest
        Register-ScheduledTask -Action \$action -Trigger \$trigger -Principal \$principal -TaskName "BoardLockAutoStart" -Description "Akıllı tahta kilidini başlatır" -Force
        ''',
      ]);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> confirmSetup() async {
    if (selectedSchoolId != null && selectedBoardName != null) {
      final version = "1.0.0"; // await ApiService.fetchLatestVersion();
      await StorageService.saveSelections(
        selectedSchoolId!.toString(),
        schools.firstWhere((s) => s.id == selectedSchoolId).name,
        selectedBoardName!,
        version!,
      );
      if (!mounted) return;
      registerAutoStartTask();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LockScreen()),
      );
    } else {
      showError("Lütfen okul ve tahta seçin");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Kurulum",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<int>(
                      dropdownColor: Colors.grey[900],
                      value: selectedSchoolId,
                      decoration: const InputDecoration(
                        labelText: "Okul Seçin",
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                      ),
                      items: schools.map((school) {
                        return DropdownMenuItem(
                          value: school.id,
                          child: Text(
                            school.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSchoolId = value;
                          boards.clear();
                        });
                        if (value != null) loadBoards(value.toString());
                      },
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[900],
                      value: selectedBoardName,
                      decoration: const InputDecoration(
                        labelText: "Tahta Seçin",
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                      ),
                      items: boards.map((board) {
                        return DropdownMenuItem(
                          value: board.name,
                          child: Text(
                            board.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedBoardName = value),
                    ),
                    const SizedBox(height: 36),
                    ElevatedButton(
                      onPressed: confirmSetup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text("Kurulumu Tamamla"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

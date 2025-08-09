import 'package:BoardLock/service/board_services.dart';
import 'package:BoardLock/service/user_session.dart';
import 'package:BoardLock/util/alert_util.dart';
import 'package:flutter/material.dart';

class BoardDetailPage extends StatelessWidget {
  final String boardName;

  const BoardDetailPage({super.key, required this.boardName});

  @override
  Widget build(BuildContext context) {
    final user = UserSession().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Kullanıcı yok")));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(boardName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  boardName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 32),
                _ActionButton(
                  icon: Icons.lock_open,
                  label: 'Kilidi Aç',
                  color: Colors.green,
                  onTap: () async {
                    final result = await BoardService.unlockBoard(
                      user.schoolId,
                      boardName,
                    );
                    AlertUtil.showCustomAlert(
                      context: context,
                      message: result
                          ? 'Tahta Kilidi Açıldı'
                          : 'Tahta Kilidi Açılamadı',
                      icon: result ? Icons.lock_open : Icons.error,
                      iconColor: result ? Colors.green : Colors.red,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _ActionButton(
                  icon: Icons.lock,
                  label: 'Kilitle',
                  color: Colors.red,
                  onTap: () async {
                    final result = await BoardService.lockBoard(
                      user.schoolId,
                      boardName,
                    );
                    AlertUtil.showCustomAlert(
                      context: context,
                      message: result
                          ? 'Tahta Kilitlendi'
                          : 'Tahta Kilitlenemedi',
                      icon: result ? Icons.lock : Icons.error,
                      iconColor: result ? Colors.red : Colors.red,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _ActionButton(
                  icon: Icons.power_settings_new,
                  label: 'Kapat',
                  color: Colors.orange,
                  onTap: () async {
                    final result = await BoardService.shutdownBoard(
                      user.schoolId,
                      boardName,
                    );
                    AlertUtil.showCustomAlert(
                      context: context,
                      message: result
                          ? 'Tahta Kapatıldı'
                          : 'Tahta Kapatılamadı',
                      icon: result ? Icons.power_settings_new : Icons.error,
                      iconColor: result ? Colors.orange : Colors.red,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _ActionButton(
                  icon: Icons.refresh,
                  label: 'Yeniden Başlat',
                  color: Colors.blueAccent,
                  onTap: () async {
                    final result = await BoardService.restartBoard(
                      user.schoolId,
                      boardName,
                    );
                    AlertUtil.showCustomAlert(
                      context: context,
                      message: result
                          ? 'Tahta Yeniden Başlatıldı'
                          : 'Tahta Yeniden Başlatılamadı',
                      icon: result ? Icons.refresh : Icons.error,
                      iconColor: result ? Colors.blueAccent : Colors.red,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}

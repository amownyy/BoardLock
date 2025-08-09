import 'package:BoardLock/service/board_services.dart';
import 'package:BoardLock/service/user_session.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final IconData boardIcon = Icons.tv;
  String selectedFilter = 'Tümü';

  Color getBoardStatusColor(String status) {
    if (status == "Aktif") return const Color(0xFFB6F5C6);
    if (status == "Kapalı") return const Color(0xFFFFB74D);
    if (status == "Kilitli") return const Color(0xFFFF8A80);
    return const Color(0xFFB2DFDB);
  }

  Color getBoardIconColor(String status) {
    if (status == "Aktif") return const Color(0xFF4CAF50);
    if (status == "Kapalı") return const Color(0xFFFF9800);
    if (status == "Kilitli") return const Color(0xFFF44336);
    return const Color(0xFF009688);
  }

  String extractClass(String boardName) {
    final match = RegExp(r'^(\w+)-').firstMatch(boardName);
    String sinif = match != null ? match.group(1)! : 'Diğer';
    switch (sinif.toUpperCase()) {
      case 'H':
      case 'HZ':
      case 'HAZIRLIK':
        return 'Hazırlık';
      case '9':
        return '9.Sınıf';
      case '10':
        return '10.Sınıf';
      case '11':
        return '11.Sınıf';
      case '12':
        return '12.Sınıf';
      default:
        return 'Diğer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Kullanıcı yok")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        flexibleSpace: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFF4F8FFF),
                child: Icon(Icons.person, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Hoşgeldiniz',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    user.schoolName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                  size: 28,
                ),
                tooltip: 'Çıkış Yap',
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('token');
                  UserSession().clear();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtre Butonları
          FutureBuilder<List<Map<String, dynamic>>>(
            future: BoardService.getBoards(user.schoolId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox();
              }
              final allBoards = snapshot.data!;
              final Set<String> availableClasses = allBoards
                  .map((b) => extractClass(b['name']))
                  .toSet();
              final List<String> filterOptions = ['Tümü', ...availableClasses];

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: filterOptions.map((option) {
                    final isSelected = selectedFilter == option;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => selectedFilter = option);
                        },
                        selectedColor: Colors.blueAccent,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          // Tahta Listesi
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: BoardService.getBoards(user.schoolId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Hiç tahta bulunamadı."));
                }

                final allBoards = snapshot.data!;
                final filteredBoards = selectedFilter == 'Tümü'
                    ? allBoards
                    : allBoards
                          .where(
                            (b) => extractClass(b['name']) == selectedFilter,
                          )
                          .toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListView.separated(
                    itemCount: filteredBoards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final board = filteredBoards[index];
                      final status = board['status'];

                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/board',
                          arguments: {'boardName': board['name']},
                        ),
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: getBoardStatusColor(status),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 24,
                                child: Icon(
                                  boardIcon,
                                  color: getBoardIconColor(status),
                                  size: 48,
                                ),
                              ),
                              Positioned(
                                bottom: 32,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      board['name'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Icon(
                                  status == "Aktif"
                                      ? Icons.lock_open
                                      : Icons.lock,
                                  color: getBoardIconColor(status),
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Resar Software Solutions © ${DateTime.now().year}',
              style: const TextStyle(fontSize: 13, color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}

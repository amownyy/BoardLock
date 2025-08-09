import 'package:BoardLock/model/user_model.dart';
import 'package:BoardLock/service/auth_services.dart';
import 'package:BoardLock/service/school_service.dart';
import 'package:BoardLock/service/user_session.dart';
import 'package:BoardLock/util/alert_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return _redirectToLogin('Oturum açılmamış. Lütfen giriş yapın.');
      }

      final userData = await AuthService.validateToken(token);
      if (userData == null) {
        return _redirectToLogin('Geçersiz oturum. Lütfen tekrar giriş yapın.');
      }

      final schoolId = userData['schoolId'].toString();
      final schoolData = await SchoolService.getSchool(schoolId);
      if (schoolData == null || schoolData['status'] != "Ödendi") {
        return _redirectToLogin(
          'Okul bilgileri alınamadı veya okul ödemesi yapılmamış. Lütfen okul yönetimi ile iletişime geçin.',
        );
      }
      userData['schoolName'] = schoolData['name'];

      UserSession().setUser(UserModel.fromJson(userData));
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      debugPrint('Auth error: $e');
      _redirectToLogin(
        'Oturum açma işlemi sırasında bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  void _redirectToLogin(String message) {
    Navigator.pushReplacementNamed(context, '/');
    AlertUtil.showCustomAlert(
      context: context,
      message: message,
      icon: Icons.error,
      iconColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/register_view.dart';
import '../view/login_view.dart';
import '../../profile/view/profile_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/bottombar_page.dart';

class SplashViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkAuthState(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Kullanıcı oturum açmışsa, BottomBarPage'e yönlendir
        if (context.mounted) {
          try {
            await _firestore.collection('users').doc(user.uid).get();
            print(
                'Kullanıcı giriş yapmış durumda, ana sayfaya yönlendiriliyor: ${user.uid}');
          } catch (e) {
            print('Firestore veri okuma hatası (önemli değil): $e');
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomBarPage()),
          );
        }
      } else {
        // Kullanıcı oturum açmamışsa giriş sayfasına yönlendir
        if (context.mounted) {
          print('Kullanıcı giriş yapmamış, login sayfasına yönlendiriliyor');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
          );
        }
      }
    } catch (e) {
      print('Oturum durumu kontrol edilirken hata: $e');
      // Hata durumunda giriş sayfasına yönlendir
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      }
    }
  }
}

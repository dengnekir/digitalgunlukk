import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get rememberMe => _rememberMe;

  LoginViewModel() {
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('savedEmail') ?? '';
    passwordController.text = prefs.getString('savedPassword') ?? '';
    _rememberMe = prefs.getBool('rememberMe') ?? false;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<UserModel?> login() async {
    try {
      setLoading(true);

      print('Giriş işlemi başlıyor');

      // Form bilgilerini al ve temizle
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        throw 'E-posta ve şifre boş olamaz';
      }

      // Direkt Firebase Auth ile giriş yap
      final auth = FirebaseAuth.instance;
      String? uid;

      try {
        // Auth işlemi
        final credentialFuture = auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final credential = await credentialFuture;
        uid = credential.user?.uid;

        if (uid == null) {
          throw 'Giriş yapılamadı';
        }

        print('Firebase Auth girişi başarılı: $uid');
      } catch (e) {
        if (e is FirebaseAuthException) {
          String errorMessage;
          switch (e.code) {
            case 'invalid-credential':
            case 'wrong-password':
              errorMessage = 'Şifre yanlış. Lütfen tekrar deneyin.';
              break;
            case 'user-not-found':
              errorMessage =
                  'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
              break;
            case 'invalid-email':
              errorMessage = 'Geçerli bir e-posta adresi giriniz.';
              break;
            case 'user-disabled':
              errorMessage = 'Bu hesap devre dışı bırakılmış.';
              break;
            case 'too-many-requests':
              errorMessage =
                  'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
              break;
            case 'operation-not-allowed':
              errorMessage = 'E-posta/şifre girişi devre dışı bırakılmış.';
              break;
            case 'firestore-error':
              errorMessage = 'Kullanıcı verileri alınırken bir hata oluştu.';
              break;
            default:
              errorMessage =
                  'Giriş yapılırken bir hata oluştu. Lütfen tekrar deneyin.';
          }
          throw errorMessage;
        }
        print('Firebase Auth giriş hatası: $e');

        // PigeonUserDetails hatası oluşsa bile, kullanıcı giriş yapmış olabilir
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          uid = currentUser.uid;
          print('Hata olmasına rağmen kullanıcı girişi bulundu: $uid');
        } else {
          throw 'Giriş işlemi başarısız. Lütfen bilgilerinizi kontrol edin';
        }
      }

      // Firestore'dan kullanıcı bilgilerini almayı dene
      String firstName = '';
      String lastName = '';
      String? profileImageUrl;

      try {
        final firestore = FirebaseFirestore.instance;
        final doc = await firestore.collection('users').doc(uid).get();

        if (doc.exists && doc.data() != null) {
          final userData = doc.data()!;
          firstName = userData['name'] as String? ?? '';
          lastName = userData['surname'] as String? ?? '';
          profileImageUrl = userData['profileImage'] as String?;

          // Kullanıcı giriş yaparken şifreyi güncelle
          await firestore.collection('users').doc(uid).update({
            'password': password,
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print('Firestore okuma hatası (önemli değil): $e');
        // Hatayı yoksay, Firebase Auth bilgileriyle devam et
      }

      // Firestore'dan bilgi alınamazsa email'i kullan
      if (firstName.isEmpty) {
        firstName = '';
        lastName = '';
        try {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && currentUser.displayName != null) {
            final nameParts = currentUser.displayName!.split(' ');
            firstName = nameParts.isNotEmpty ? nameParts.first : '';
            lastName = nameParts.length > 1 ? nameParts.last : '';
            profileImageUrl = currentUser.photoURL;
          }
        } catch (e) {
          print('DisplayName okuma hatası (önemli değil): $e');
        }
      }

      // Kullanıcı modeli oluştur
      final user = UserModel(
        uid: uid!,
        name: firstName,
        surname: lastName,
        email: email,
        profileImage: profileImageUrl,
      );

      // Hatırla özelliği için bilgileri kaydet
      if (_rememberMe) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('savedEmail', email);
          await prefs.setString('savedPassword', password);
          await prefs.setBool('rememberMe', true);
        } catch (e) {
          print('SharedPreferences hatası (önemli değil): $e');
        }
      } else {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('savedEmail');
          await prefs.remove('savedPassword');
          await prefs.remove('rememberMe');
        } catch (e) {
          print('SharedPreferences silme hatası (önemli değil): $e');
        }
      }

      print('Giriş işlemi başarılı');
      return user;
    } catch (e) {
      print('Giriş hatası: $e');

      // PigeonUserDetails hatası kontrolü
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List<Object?>') ||
          e.toString().contains('type cast')) {
        // Auth başarılı olabilir, kullanıcı bilgilerini Firebase Auth'tan al
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final user = UserModel(
            uid: currentUser.uid,
            name: '',
            surname: '',
            email: currentUser.email ?? emailController.text.trim(),
            profileImage: currentUser.photoURL,
          );

          if (_rememberMe) {
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('savedEmail', emailController.text.trim());
              await prefs.setString('savedPassword', passwordController.text);
              await prefs.setBool('rememberMe', true);
            } catch (e) {
              print('SharedPreferences hatası (önemli değil): $e');
            }
          }

          return user;
        }
      }

      // String hatalar için
      if (e is String) {
        throw e;
      } else if (e is FirebaseAuthException) {
        // Firebase Auth hatalarını kullanıcı dostu hale getir
        String errorMessage;
        switch (e.code) {
          case 'invalid-credential':
          case 'wrong-password':
            errorMessage = 'Şifre yanlış. Lütfen tekrar deneyin.';
            break;
          case 'user-not-found':
            errorMessage =
                'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
            break;
          case 'invalid-email':
            errorMessage = 'Geçerli bir e-posta adresi giriniz.';
            break;
          case 'user-disabled':
            errorMessage = 'Bu hesap devre dışı bırakılmış.';
            break;
          case 'too-many-requests':
            errorMessage =
                'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'E-posta/şifre girişi devre dışı bırakılmış.';
            break;
          case 'firestore-error':
            errorMessage = 'Kullanıcı verileri alınırken bir hata oluştu.';
            break;
          default:
            errorMessage =
                'Giriş yapılırken bir hata oluştu. Lütfen tekrar deneyin.';
        }
        throw errorMessage;
      } else {
        throw 'Giriş yapılırken bir hata oluştu. Lütfen tekrar deneyin.';
      }
    } finally {
      setLoading(false);
    }
  }

  Future<void> resetPassword() async {
    if (emailController.text.isEmpty) {
      throw 'Lütfen e-posta adresinizi girin';
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
    } catch (e) {
      if (e is FirebaseAuthException) {
        String errorMessage;
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Geçerli bir e-posta adresi giriniz.';
            break;
          case 'user-not-found':
            errorMessage =
                'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
            break;
          case 'too-many-requests':
            errorMessage =
                'Çok fazla sıfırlama denemesi. Lütfen daha sonra tekrar deneyin.';
            break;
          default:
            errorMessage =
                'Şifre sıfırlama işlemi başarısız oldu. Lütfen tekrar deneyin.';
        }
        throw errorMessage;
      } else {
        throw 'Şifre sıfırlama işlemi başarısız oldu. Lütfen tekrar deneyin.';
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

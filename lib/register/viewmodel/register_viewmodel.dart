import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _isLoading = false;
  int _currentStep = 0;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  int get currentStep => _currentStep;
  String? get errorMessage => _errorMessage;

  // Form controllers
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Doğrudan kayıt işlemi
  Future<UserModel?> register() async {
    try {
      setLoading(true);
      setErrorMessage(null);

      // Form bilgilerini al ve temizle
      final name = nameController.text.trim();
      final surname = surnameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;

      // Temel doğrulama
      if (name.isEmpty || surname.isEmpty) {
        throw 'Ad ve soyad boş olamaz';
      }

      if (email.isEmpty) {
        throw 'E-posta adresi boş olamaz';
      }

      if (password.isEmpty) {
        throw 'Şifre boş olamaz';
      }

      if (password != confirmPassword) {
        throw 'Şifreler eşleşmiyor';
      }

      print('Kayıt işlemi başlıyor: $email');

      String? uid;
      try {
        // 1. Auth işlemleri
        final credentialFuture =
            FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // 2. Auth sonucunu bekle
        final credential = await credentialFuture;
        uid = credential.user?.uid;

        if (uid == null) {
          throw 'Kullanıcı kaydı oluşturulamadı';
        }

        print('Firebase Auth kaydı başarılı: $uid');
      } catch (e) {
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              throw 'Bu e-posta adresi zaten kullanımda';
            case 'invalid-email':
              throw 'Geçersiz e-posta formatı';
            case 'weak-password':
              throw 'Şifre çok zayıf, en az 6 karakter kullanın';
            case 'operation-not-allowed':
              throw 'E-posta/şifre ile kayıt şu anda devre dışı';
            case 'too-many-requests':
              throw 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin';
            default:
              throw 'Kayıt sırasında hata: ${e.message}';
          }
        }
        print('Firebase Auth hatası: $e');
        // PigeonUserDetails hatası burada oluşabilir, o yüzden kullanıcı kontrolü yap
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Kullanıcı kaydı oluşmuş ama hata alınmış
          uid = currentUser.uid;
          print('Hata olmasına rağmen kullanıcı kaydı bulundu: $uid');
        } else {
          throw 'Kayıt işlemi başarısız. Lütfen tekrar deneyin';
        }
      }

      // Kullanıcı modelini oluştur
      final userModel = UserModel(
        uid: uid!,
        name: name,
        surname: surname,
        email: email,
        profileImage: null,
      );

      try {
        // Firestore kayıt işlemi
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(uid).set({
          'uid': uid,
          'name': name,
          'surname': surname,
          'email': email,
          'password': password,
          'profileImage': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Firestore kaydı başarılı');
      } catch (e) {
        print('Firestore kayıt hatası (kritik değil): $e');
        // Firestore hatası kritik değil, kullanıcı modeli döndürülebilir
      }

      print('Kayıt işlemi tamamlandı');
      return userModel;
    } catch (e) {
      print('Kayıt hatası: $e');
      // Herhangi bir String hatayı doğrudan fırlat
      if (e is String) {
        throw e;
      } else if (e is FirebaseAuthException) {
        throw e.message ?? 'Bilinmeyen kimlik doğrulama hatası';
      } else {
        throw 'Kayıt işlemi hatası: $e';
      }
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

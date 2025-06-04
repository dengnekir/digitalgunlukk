import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  UserModel? _user;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  AuthViewModel() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          // Firestore'dan kullanıcı bilgilerini al
          final userData = await _authService.getUserData(user.uid);
          if (userData != null) {
            _user = userData;
          }
          _status = AuthStatus.authenticated;
        } catch (e) {
          print('Kullanıcı bilgileri alınamadı: $e');
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.loginWithEmail(email, password);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> register(
      String email, String password, String name, String surname) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
        surname: surname,
        profileImagePath: null,
      );

      if (_user != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.error;
        _errorMessage = "Kayıt işlemi başarısız";
      }
    } catch (e) {
      print('Auth viewmodel register hatası: $e');
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }
}

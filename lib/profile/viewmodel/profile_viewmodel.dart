import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  UserModel? _userModel;
  bool _notificationsEnabled = true;

  bool get isLoading => _isLoading;
  UserModel? get userModel => _userModel;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> loadUserData() async {
    setLoading(true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _userModel = await _authService.getUserData(currentUser.uid);
      }
    } catch (e) {
      print('Kullanıcı bilgileri yüklenirken hata: $e');
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signOut() async {
    setLoading(true);
    try {
      await _authService.signOut();
      _userModel = null;
    } catch (e) {
      print('Çıkış yaparken hata: $e');
    } finally {
      setLoading(false);
    }
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  Future<void> updateUserNameAndSurname(
      String newName, String newSurname) async {
    setLoading(true);
    try {
      if (_userModel != null) {
        _userModel = _userModel!.copyWith(name: newName, surname: newSurname);
        // Firestore'da kullanıcı verilerini güncellemek için AuthService kullan
        await _authService.updateUserData(_userModel!);
        notifyListeners();
      }
    } catch (e) {
      print('İsim/Soyisim güncellenirken hata: $e');
    } finally {
      setLoading(false);
    }
  }
}

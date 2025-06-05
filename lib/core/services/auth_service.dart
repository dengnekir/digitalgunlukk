import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Mevcut kullanıcı durumunu stream olarak dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Kullanıcı bilgilerini direkt Firebase Auth'dan ve Firestore'dan al
  Future<UserModel?> getUserData(String uid) async {
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser != null && authUser.uid == uid) {
        // Firestore'dan kullanıcı bilgilerini al
        final docSnapshot = await _firestore.collection('users').doc(uid).get();
        if (docSnapshot.exists) {
          final userData = docSnapshot.data();
          return UserModel(
            uid: uid,
            name: userData?['name'] ?? '',
            surname: userData?['surname'] ?? '',
            email: authUser.email ?? '',
            profileImage: authUser.photoURL ?? userData?['profileImage'],
          );
        } else {
          // Firestore'da belge yoksa Firebase Auth bilgilerini kullan
          String firstName = '';
          String lastName = '';

          if (authUser.displayName != null) {
            final nameParts = authUser.displayName!.split(' ');
            firstName = nameParts.isNotEmpty ? nameParts.first : '';
            lastName = nameParts.length > 1 ? nameParts.last : '';
          }

          return UserModel(
            uid: uid,
            name: firstName,
            surname: lastName,
            email: authUser.email ?? '',
            profileImage: authUser.photoURL,
          );
        }
      }

      return null;
    } catch (e) {
      print('Kullanıcı bilgileri alınamadı: $e');
      return null;
    }
  }

  // Firebase Storage'a profil resmi yükleme
  Future<String?> _uploadProfileImageToStorage(
      String imagePath, String userId) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef =
            _storage.ref().child('users/$userId/profile_images/$fileName');

        await storageRef.putFile(file);
        return await storageRef.getDownloadURL();
      }
    } catch (e) {
      print('Profil resmi yükleme hatası: $e');
    }
    return null;
  }

  // Güvenli bir şekilde Firestore'a kullanıcı kaydetme
  Future<bool> saveUserToFirestore(
      UserModel user, String? profileImagePath) async {
    try {
      print('Firestore kayıt başlıyor...');
      print('UID: ${user.uid}');

      // Kullanıcı dokümanı referansını oluştur
      final docRef = _firestore.collection('users').doc(user.uid);

      // Profil resmini yükle (eğer varsa)
      String? profileImageUrl;
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        try {
          profileImageUrl =
              await _uploadProfileImageToStorage(profileImagePath, user.uid);
          user.profileImage = profileImageUrl; // UserModel'i güncelle
        } catch (e) {
          print('Profil resmi yükleme hatası: $e');
          // Resim yükleme hatası kritik değil, devam et
        }
      }

      // Tip güvenliği için tüm alanları string olarak dönüştür
      // Firestore için güvenli veri oluştur
      final Map<String, dynamic> userData = {
        'uid': user.uid.toString(),
        'name': user.name.toString(),
        'surname': user.surname.toString(),
        'email': user.email.toString(),
        'profileImage': profileImageUrl?.toString(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Veriyi kaydet
      try {
        print('Doküman kaydediliyor...');
        await docRef.set(userData, SetOptions(merge: true));
        print('Firestore kayıt başarılı!');

        return true;
      } catch (e) {
        print('Firestore kayıt hatası: $e');
        return false;
      }
    } catch (e) {
      print('Genel kayıt hatası: $e');
      return false;
    }
  }

  // Kullanıcı bilgilerini Firestore'da güncelleme
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.name,
        'surname': user.surname,
        'email': user.email,
        // Profil resmi alanı varsa buraya eklenmeli
      }, SetOptions(merge: true));
    } catch (e) {
      print('Kullanıcı bilgileri güncellenirken hata: $e');
      rethrow;
    }
  }

  // Kullanıcı kaydı - Firebase Authentication ve Firestore
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String surname,
    String? profileImagePath,
  }) async {
    try {
      print(
          "Kayıt işlemi başlıyor: email=$email, name=$name, surname=$surname");

      // 1. Önce sadece Firebase Authentication ile kayıt yap
      UserCredential? userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        // DisplayName değerini ayarla - bu PigeonUserDetails hatasını önleyebilir
        if (userCredential.user != null) {
          try {
            await userCredential.user!.updateDisplayName('$name $surname');
            // Güncellemeden sonra kısa bir bekleme ekle
            await Future.delayed(const Duration(milliseconds: 500));
          } catch (profileError) {
            print(
                'DisplayName güncelleme hatası (kritik değil): $profileError');
            // Bu hata kritik değil, kayıt sürecine devam edilebilir
          }
        }
      } catch (e) {
        print('Firebase Auth kayıt hatası: $e');
        rethrow;
      }

      if (userCredential.user == null) {
        throw Exception('Kullanıcı oluşturulamadı');
      }

      // Kullanıcı kimliğini al
      final uid = userCredential.user!.uid;

      // 2. UserModel oluştur
      final userModel = UserModel(
        uid: uid,
        name: name.trim(),
        surname: surname.trim(),
        email: email.trim(),
        profileImage: null,
      );

      // 3. Firestore'a kaydet
      try {
        bool isFirestoreSuccess =
            await saveUserToFirestore(userModel, profileImagePath);

        if (!isFirestoreSuccess) {
          print(
              'Firestore kayıt başarısız, ancak Auth kayıt başarılı. Devam edilebilir.');
          // Firestore'a kayıt başarısız olsa bile AuthModel çalışmaya devam edebilir.
        }
      } catch (firestoreError) {
        print('Firestore kayıt hatası (kritik değil): $firestoreError');
        // Firestore hatası kritik değil, UserModel'i döndürebiliriz
      }

      return userModel;
    } catch (e) {
      print('Kayıt işlemi hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı girişi - Güvenli yaklaşım
  Future<UserModel?> loginWithEmail(String email, String password) async {
    try {
      // 1. Firebase Authentication ile giriş yap
      UserCredential? userCredential;
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      } catch (e) {
        print('Firebase Auth giriş hatası: $e');
        rethrow;
      }

      if (userCredential.user == null) {
        throw Exception('Giriş yapılamadı');
      }

      // 2. Kullanıcı kimliğini al
      final uid = userCredential.user!.uid;

      // 3. Direkt olarak User nesnesi üzerinden UserModel oluştur
      return UserModel(
        uid: uid,
        name: userCredential.user?.displayName?.split(' ').first ?? '',
        surname: userCredential.user?.displayName?.split(' ').last ?? '',
        email: userCredential.user?.email ?? '',
        profileImage: userCredential.user?.photoURL,
      );
    } catch (e) {
      print('Giriş işlemi hatası: $e');
      rethrow;
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}

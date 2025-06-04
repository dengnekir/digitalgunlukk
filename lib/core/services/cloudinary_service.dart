import 'dart:io';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import '../config/app_config.dart';

class CloudinaryService {
  late final Cloudinary _cloudinary;

  CloudinaryService() {
    _cloudinary = Cloudinary.full(
      apiKey: AppConfig.cloudinaryApiKey,
      apiSecret: AppConfig.cloudinaryApiSecret,
      cloudName: AppConfig.cloudinaryCloudName,
    );
  }

  /// Kullanıcı profil resmini Cloudinary'ye yükler
  Future<String?> uploadProfileImage(String filePath, String userId) async {
    try {
      if (filePath.isEmpty) return null;

      final file = File(filePath);
      if (!await file.exists()) {
        print('Dosya bulunamadı: $filePath');
        return null;
      }

      print('Cloudinary\'ye profil resmi yükleniyor...');

      final response = await _cloudinary.uploadResource(
        CloudinaryUploadResource(
          filePath: filePath,
          fileBytes: await file.readAsBytes(),
          resourceType: CloudinaryResourceType.image,
          folder: 'user_profiles/$userId',
          fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}',
          uploadPreset: AppConfig.cloudinaryUploadPreset,
          progressCallback: (count, total) {
            print('Yükleniyor: ${(count / total * 100).toStringAsFixed(2)}%');
          },
        ),
      );

      if (response.isSuccessful && response.secureUrl != null) {
        print('Cloudinary yükleme başarılı: ${response.secureUrl}');
        return response.secureUrl;
      } else {
        print('Cloudinary yükleme başarısız: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Cloudinary yükleme hatası: $e');
      return null;
    }
  }

  /// Genel resim yükleme metodu
  Future<String?> uploadImage(String filePath, String folder) async {
    try {
      if (filePath.isEmpty) return null;

      final file = File(filePath);
      if (!await file.exists()) {
        print('Dosya bulunamadı: $filePath');
        return null;
      }

      final response = await _cloudinary.uploadResource(
        CloudinaryUploadResource(
          filePath: filePath,
          fileBytes: await file.readAsBytes(),
          resourceType: CloudinaryResourceType.image,
          folder: folder,
          fileName: 'image_${DateTime.now().millisecondsSinceEpoch}',
          uploadPreset: AppConfig.cloudinaryUploadPreset,
        ),
      );

      if (response.isSuccessful && response.secureUrl != null) {
        return response.secureUrl;
      } else {
        print('Cloudinary yükleme başarısız: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Cloudinary yükleme hatası: $e');
      return null;
    }
  }

  /// Cloudinary'deki bir resmi siler
  Future<bool> deleteImage(String publicId) async {
    try {
      final response = await _cloudinary.deleteResource(
        url: publicId,
        resourceType: CloudinaryResourceType.image,
      );

      return response.isSuccessful;
    } catch (e) {
      print('Cloudinary silme hatası: $e');
      return false;
    }
  }
}

class Validators {
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş olamaz';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    if (!RegExp(r'^[a-zA-Z0-9.]+$').hasMatch(value)) {
      return 'Şifre sadece harf, rakam ve nokta içerebilir';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Şifre en az bir büyük harf içermelidir';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Şifre en az bir küçük harf içermelidir';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Şifre en az bir rakam içermelidir';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi boş olamaz';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    return null;
  }
}

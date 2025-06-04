import 'package:flutter/material.dart';

class colorss {
  static const Color primaryColor = Color(0xFF673AB7); // Derin Mor
  static const Color primaryColorLight = Color(0xFF9575CD); // Açık Mor
  static const Color primaryColorDark = Color(0xFF512DA8); // Koyu Mor
  static const Color secondaryColor =
      Color(0xFF3F51B5); // İkincil Vurgu - Lacivert

  static const Color premiumGradientStart =
      Color(0xFF8E2DE2); // Premium gradient başlangıç rengi
  static const Color premiumGradientEnd =
      Color(0xFF4A00E0); // Premium gradient bitiş rengi
  static const Color logoutButtonColor =
      Color(0xFFE53935); // Çıkış butonu rengi

  static const Color backgroundColor = Colors.white;
  static const Color backgroundColorDark = Colors.grey;
  static const Color backgroundColorLight =
      Colors.white; // Açık siyah yerine beyaz yaptım

  static const Color textColor = Colors.black; // Beyaz yerine siyah yaptım
  static const Color textColorSecondary =
      Colors.black54; // Beyaz70 yerine siyah54 yaptım

  static Color getBackgroundGradientStart() => backgroundColor;
  static Color getBackgroundGradientEnd() =>
      backgroundColorDark.withOpacity(0.8);

  static Color getPrimaryGlowColor() => primaryColor.withOpacity(0.2);
  static Color getSecondaryGlowColor() => Colors.transparent;

  static Color getOverlayColor() => backgroundColorDark.withOpacity(0.5);

  static MaterialStateProperty<Color> getPrimaryButtonColor() {
    return MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return primaryColorDark;
        }
        return primaryColor;
      },
    );
  }

  static MaterialStateProperty<Color> getCheckboxColor() {
    return MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return textColor;
      },
    );
  }

  static BoxDecoration getInputDecoration() {
    return BoxDecoration(
      color: textColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: primaryColor.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  static InputDecoration getTextFieldDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: textColorSecondary),
      prefixIcon: Icon(prefixIcon, color: primaryColor.withOpacity(0.7)),
      suffixIcon: suffixIcon,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }

  static ButtonStyle getPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      shadowColor: primaryColor.withOpacity(0.5),
    );
  }
}

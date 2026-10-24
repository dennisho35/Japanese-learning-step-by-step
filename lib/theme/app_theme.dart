import 'package:flutter/material.dart';

/// 日語一步通 Design System
/// 色彩規範：米白和紙底色 (#FAF8F5)、深藍靛色 (#1B365D)、朱紅鳥居點綴 (#D64045)
class AppTheme {
  static const Color primaryIndigo = Color(0xFF1B365D);
  static const Color accentVermilion = Color(0xFFD64045);
  static const Color washiCream = Color(0xFFFAF8F5);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color bambooGreen = Color(0xFF2E7D32);
  static const Color amberGold = Color(0xFFD97706);

  static ThemeData lightTheme(double fontScale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: washiCream,
      cardColor: cardLight,
      colorScheme: const ColorScheme.light(
        primary: primaryIndigo,
        secondary: accentVermilion,
        surface: cardLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryIndigo,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData darkTheme(double fontScale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF60A5FA),
        secondary: Color(0xFFF87171),
        surface: darkSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

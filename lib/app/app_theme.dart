import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ================= COLORS =================
  static const Color primary = Color(0xFF22C55E); // Raonson green
  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFF6F6F6);

  static const Color textDark = Colors.white;
  static const Color textLight = Colors.black;

  static const Color muted = Colors.grey;
  static const Color danger = Colors.redAccent;

  // ================= TEXT THEME =================
  static TextTheme _textTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: color,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: color.withOpacity(0.9),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: color.withOpacity(0.7),
      ),
    );
  }

  // ================= DARK THEME =================
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        background: backgroundDark,
        surface: surfaceDark,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundDark,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: _textTheme(textDark),
      iconTheme: const IconThemeData(color: Colors.white),
      dividerColor: Colors.grey.shade800,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ================= LIGHT THEME =================
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        background: backgroundLight,
        surface: surfaceLight,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundLight,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: _textTheme(textLight),
      iconTheme: const IconThemeData(color: Colors.black),
      dividerColor: Colors.grey.shade300,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primary = Color(0xFF5B3EFF);
  static const _surface = Color(0xFF0F1020);
  static const _card = Color(0xFF17182B);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _surface,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        surface: _surface,
        secondary: Color(0xFF38BDF8),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardColor: _card,
      useMaterial3: true,
    );
  }
}

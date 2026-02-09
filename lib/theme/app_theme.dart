import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

/// Central App Theme for Raonson
/// Version: v5 (Full Social Network)
/// Light + Dark themes

class AppTheme {
  AppTheme._();

  // ================= LIGHT THEME =================
  static final ThemeData light = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    primaryColor: AppColors.primary,

    // ---------- APP BAR ----------
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimaryLight,
      centerTitle: false,
      titleTextStyle: AppTextStyles.appTitle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryLight,
      ),
    ),

    // ---------- TEXT ----------
    textTheme: const TextTheme(
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.bodySmall,
      titleLarge: AppTextStyles.screenTitle,
      titleMedium: AppTextStyles.sectionTitle,
      labelLarge: AppTextStyles.buttonPrimary,
      labelMedium: AppTextStyles.caption,
    ).apply(
      bodyColor: AppColors.textPrimaryLight,
      displayColor: AppColors.textPrimaryLight,
    ),

    // ---------- ICONS ----------
    iconTheme: const IconThemeData(
      color: AppColors.textPrimaryLight,
      size: 22,
    ),

    // ---------- BUTTONS ----------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.buttonPrimary,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimaryLight,
        side: const BorderSide(color: AppColors.borderLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.buttonSecondary,
      ),
    ),

    // ---------- INPUT ----------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackgroundLight,
      hintStyle: AppTextStyles.inputHint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
    ),

    // ---------- DIVIDER ----------
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 0.5,
    ),

    // ---------- BOTTOM NAV ----------
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundLight,
      selectedItemColor: AppColors.textPrimaryLight,
      unselectedItemColor: AppColors.textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );

  // ================= DARK THEME =================
  static final ThemeData dark = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    primaryColor: AppColors.primary,

    // ---------- APP BAR ----------
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimaryDark,
      centerTitle: false,
      titleTextStyle: AppTextStyles.appTitle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
      ),
    ),

    // ---------- TEXT ----------
    textTheme: const TextTheme(
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.bodySmall,
      titleLarge: AppTextStyles.screenTitle,
      titleMedium: AppTextStyles.sectionTitle,
      labelLarge: AppTextStyles.buttonPrimary,
      labelMedium: AppTextStyles.caption,
    ).apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    ),

    // ---------- ICONS ----------
    iconTheme: const IconThemeData(
      color: AppColors.textPrimaryDark,
      size: 22,
    ),

    // ---------- BUTTONS ----------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.buttonPrimary,
      ),
    ),

    // ---------- INPUT ----------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackgroundDark,
      hintStyle: AppTextStyles.inputHint.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
    ),

    // ---------- DIVIDER ----------
    dividerTheme: const DividerThemeData(
      color: AppColors.borderDark,
      thickness: 0.5,
    ),

    // ---------- BOTTOM NAV ----------
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundDark,
      selectedItemColor: AppColors.textPrimaryDark,
      unselectedItemColor: AppColors.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}

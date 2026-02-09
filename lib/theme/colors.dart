import 'package:flutter/material.dart';

/// Central color system for Raonson App
/// Version: v5 (Full Social Network)

class AppColors {
  AppColors._();

  // ================= BRAND =================
  static const Color primary = Color(0xFF1877F2); // Instagram blue
  static const Color secondary = Color(0xFF1DA1F2);
  static const Color accent = Color(0xFF00C853); // green verified

  // ================= BACKGROUND =================
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F1424);

  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF1C2238);

  // ================= TEXT =================
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  static const Color textHint = Color(0xFF9E9E9E);

  // ================= ICONS =================
  static const Color iconLight = Color(0xFF000000);
  static const Color iconDark = Color(0xFFFFFFFF);
  static const Color iconMuted = Color(0xFF9CA3AF);

  // ================= BUTTONS =================
  static const Color buttonPrimary = primary;
  static const Color buttonDisabled = Color(0xFFBDBDBD);
  static const Color buttonTextLight = Colors.white;
  static const Color buttonTextDark = Colors.white;

  // ================= INPUT =================
  static const Color inputBackgroundLight = Color(0xFFF0F2F5);
  static const Color inputBackgroundDark = Color(0xFF20263D);
  static const Color inputBorder = Color(0xFFE5E7EB);
  static const Color inputFocused = primary;

  // ================= DIVIDER =================
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF2A2F45);

  // ================= STATES =================
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF0288D1);

  // ================= POST / REEL =================
  static const Color like = Color(0xFFE53935);
  static const Color save = Color(0xFF1877F2);
  static const Color comment = Color(0xFF9CA3AF);
  static const Color share = Color(0xFF9CA3AF);

  // ================= CHAT =================
  static const Color chatBubbleMe = Color(0xFF1877F2);
  static const Color chatBubbleOther = Color(0xFFE5E7EB);

  static const Color chatTextMe = Colors.white;
  static const Color chatTextOther = Color(0xFF111827);

  // ================= STORY =================
  static const List<Color> storyGradient = [
    Color(0xFF9B2282),
    Color(0xFFEE2A7B),
    Color(0xFFF99D3A),
  ];

  // ================= OVERLAYS =================
  static const Color overlayDark = Color(0x99000000);
  static const Color overlayLight = Color(0x66FFFFFF);

  // ================= NAVIGATION =================
  static const Color bottomNavBackgroundLight = Colors.white;
  static const Color bottomNavBackgroundDark = Color(0xFF0F1424);

  static const Color bottomNavActive = Color(0xFF000000);
  static const Color bottomNavInactive = Color(0xFF9CA3AF);

  // ================= SHADOW =================
  static const Color shadow = Color(0x1A000000);
}

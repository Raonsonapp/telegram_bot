import 'package:flutter/material.dart';
import 'colors.dart';

/// Central text styles for Raonson App
/// Version: v5 (Full Social Network)

class AppTextStyles {
  AppTextStyles._();

  // ================= HEADERS =================
  static const TextStyle appTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ================= BODY =================
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  // ================= CAPTIONS =================
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle captionMuted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryLight,
  );

  // ================= USERNAME =================
  static const TextStyle username = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle usernameLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  // ================= STATS =================
  static const TextStyle statNumber = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // ================= BUTTONS =================
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ================= INPUT =================
  static const TextStyle input = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  // ================= CHAT =================
  static const TextStyle chatMessage = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle chatTime = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryLight,
  );

  // ================= REELS =================
  static const TextStyle reelUsername = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle reelCaption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  // ================= ERRORS / INFO =================
  static const TextStyle error = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );

  static const TextStyle success = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
  );

  static const TextStyle link = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
}

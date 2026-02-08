import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ====== APP BAR / LOGO ======
  static const TextStyle appTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  // ====== USERNAME ======
  static const TextStyle username = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle usernameSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ====== CAPTION / BODY ======
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // ====== COUNTS (likes, followers) ======
  static const TextStyle count = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle countLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // ====== BUTTONS ======
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // ====== INPUTS ======
  static const TextStyle inputText = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    color: AppColors.inputHint,
  );

  // ====== TIME / META ======
  static const TextStyle time = TextStyle(
    fontSize: 11,
    color: AppColors.textSecondary,
  );

  static const TextStyle meta = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // ====== ERROR / STATUS ======
  static const TextStyle error = TextStyle(
    fontSize: 13,
    color: AppColors.error,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle success = TextStyle(
    fontSize: 13,
    color: AppColors.success,
    fontWeight: FontWeight.w500,
  );

  // ====== PROFILE ======
  static const TextStyle profileName = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle profileBio = TextStyle(
    fontSize: 13,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ====== TAB LABEL ======
  static const TextStyle tabLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

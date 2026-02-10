import 'package:flutter/foundation.dart';

/// =====================================================
/// AppConfig
/// -----------------------------------------------------
/// Global static configuration for Raonson app
/// - Environment
/// - API
/// - Feature flags
/// - Limits & constants
/// =====================================================
class AppConfig {
  AppConfig._();

  // ================= ENV =================
  static const bool isDebug = kDebugMode;
  static const bool isRelease = kReleaseMode;

  // ================= APP =================
  static const String appName = 'Raonson';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // ================= API =================
  /// Base backend URL (your server)
  static const String baseUrl =
      'https://raonson-me.onrender.com';

  static const Duration connectTimeout =
      Duration(seconds: 15);
  static const Duration receiveTimeout =
      Duration(seconds: 20);

  // ================= AUTH =================
  static const Duration tokenRefreshThreshold =
      Duration(minutes: 5);

  static const Duration sessionIdleTimeout =
      Duration(days: 30);

  // ================= UPLOAD LIMITS =================
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;

  static const int maxPostImages = 10;
  static const int maxStoryDurationSeconds = 15;
  static const int maxReelDurationSeconds = 90;

  // ================= PAGINATION =================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // ================= CACHE =================
  static const Duration cacheTTL =
      Duration(minutes: 10);

  static const Duration imageCacheTTL =
      Duration(hours: 24);

  // ================= FEATURES =================
  static const bool enableStories = true;
  static const bool enableReels = true;
  static const bool enableChat = true;
  static const bool enableNotifications = true;
  static const bool enableSearch = true;

  // ================= UI =================
  static const double avatarRadius = 22;
  static const double verifiedBadgeSize = 14;

  // ================= SECURITY =================
  static const int maxLoginAttempts = 5;
  static const Duration loginBlockDuration =
      Duration(minutes: 15);

  // ================= SOCKET =================
  static const bool enableRealtime = true;
  static const Duration socketReconnectDelay =
      Duration(seconds: 5);

  // ================= LOGGING =================
  static bool get enableLogs => isDebug;

  // ================= HELPERS =================
  static String get apiBase =>
      '$baseUrl/api';

  static String versionString() =>
      '$appVersion+$buildNumber';
}

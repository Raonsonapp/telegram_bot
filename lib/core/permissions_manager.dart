// lib/core/permissions_manager.dart
// =====================================================
// PERMISSIONS MANAGER – Raonson
// Handles runtime permissions in one place
// Android / iOS safe wrappers
// =====================================================

import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

enum AppPermission {
  camera,
  microphone,
  photos,
  storage,
  notifications,
}

class PermissionsManager {
  PermissionsManager._();

  // =========================
  // PUBLIC API
  // =========================

  static Future<bool> request(AppPermission permission) async {
    final status = await _permission(permission).request();
    return status.isGranted;
  }

  static Future<bool> check(AppPermission permission) async {
    final status = await _permission(permission).status;
    return status.isGranted;
  }

  static Future<Map<AppPermission, bool>> requestMultiple(
    List<AppPermission> permissions,
  ) async {
    final result = <AppPermission, bool>{};

    for (final p in permissions) {
      final granted = await request(p);
      result[p] = granted;
    }

    return result;
  }

  static Future<bool> openAppSettingsSafe() async {
    return await openAppSettings();
  }

  // =========================
  // INTERNAL
  // =========================

  static Permission _permission(AppPermission p) {
    switch (p) {
      case AppPermission.camera:
        return Permission.camera;

      case AppPermission.microphone:
        return Permission.microphone;

      case AppPermission.photos:
        if (Platform.isIOS) {
          return Permission.photos;
        }
        return Permission.storage;

      case AppPermission.storage:
        return Permission.storage;

      case AppPermission.notifications:
        return Permission.notification;
    }
  }

  // =========================
  // HIGH LEVEL HELPERS
  // =========================

  /// Needed for reels, stories, avatar upload
  static Future<bool> mediaPermissions() async {
    final res = await requestMultiple([
      AppPermission.camera,
      AppPermission.microphone,
      AppPermission.photos,
    ]);

    return !res.values.contains(false);
  }

  /// Needed for chat attachments
  static Future<bool> attachmentPermissions() async {
    final res = await requestMultiple([
      AppPermission.photos,
      AppPermission.storage,
    ]);

    return !res.values.contains(false);
  }

  /// Notifications permission (iOS mostly)
  static Future<bool> notificationsPermission() async {
    if (!Platform.isIOS) return true;
    return await request(AppPermission.notifications);
  }
}

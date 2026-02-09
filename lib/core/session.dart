/// =====================================================
/// SESSION MANAGER – RAONSON CORE
/// Handles auth session lifecycle
/// =====================================================

import 'dart:async';

import 'token_storage.dart';
import 'http_client.dart';
import 'api.dart';

class SessionManager {
  SessionManager._();

  static Timer? _refreshTimer;

  // ================= INIT =================
  /// Call on app start
  static Future<void> init() async {
    final hasSession = await TokenStorage.hasSession();
    if (hasSession) {
      _scheduleRefresh();
    }
  }

  // ================= LOGIN =================
  static Future<void> startSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    await TokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    _scheduleRefresh();
  }

  // ================= LOGOUT =================
  static Future<void> endSession() async {
    _cancelRefresh();
    await TokenStorage.clear();
  }

  // ================= REFRESH =================
  static Future<bool> refreshSession() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final res = await HttpClient.post(
        Api.refreshToken,
        body: {
          'refresh_token': refreshToken,
        },
        auth: false,
      );

      if (res is Map &&
          res['access_token'] != null &&
          res['refresh_token'] != null) {
        await TokenStorage.saveTokens(
          accessToken: res['access_token'],
          refreshToken: res['refresh_token'],
        );
        _scheduleRefresh();
        return true;
      }
    } catch (_) {
      // ignore
    }

    await endSession();
    return false;
  }

  // ================= TIMER =================
  static void _scheduleRefresh() {
    _cancelRefresh();

    // refresh every 25 minutes (safe default)
    _refreshTimer = Timer(
      const Duration(minutes: 25),
      refreshSession,
    );
  }

  static void _cancelRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}

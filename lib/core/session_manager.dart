// lib/core/session_manager.dart
// =====================================================
// SESSION MANAGER – FULL v1
// Handles:
// - Login state
// - Current user session
// - Token lifecycle
// - Session restore / destroy
// =====================================================

import 'dart:async';

import 'token_storage.dart';
import 'api.dart';
import 'http_client.dart';

class SessionManager {
  SessionManager._();

  // =====================================================
  // INTERNAL STATE
  // =====================================================

  static String? _accessToken;
  static String? _refreshToken;
  static bool _initialized = false;

  // =====================================================
  // INIT (CALL ON APP START)
  // =====================================================

  static Future<void> init() async {
    if (_initialized) return;

    _accessToken = await TokenStorage.getAccessToken();
    _refreshToken = await TokenStorage.getRefreshToken();

    _initialized = true;
  }

  // =====================================================
  // GETTERS
  // =====================================================

  static bool get isLoggedIn =>
      _accessToken != null && _accessToken!.isNotEmpty;

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;

  // =====================================================
  // SET SESSION (AFTER LOGIN / REGISTER)
  // =====================================================

  static Future<void> setSession({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    await TokenStorage.saveAccessToken(accessToken);
    if (refreshToken != null) {
      await TokenStorage.saveRefreshToken(refreshToken);
    }
  }

  // =====================================================
  // CLEAR SESSION (LOGOUT)
  // =====================================================

  static Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;

    await TokenStorage.clearAll();
  }

  // =====================================================
  // REFRESH TOKEN
  // =====================================================

  static Future<bool> refreshSession() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      await clearSession();
      return false;
    }

    try {
      final res = await HttpClient.post(
        Api.refresh,
        body: {
          'refresh_token': _refreshToken,
        },
        auth: false,
      );

      if (res is Map && res['access_token'] != null) {
        await setSession(
          accessToken: res['access_token'],
          refreshToken: res['refresh_token'],
        );
        return true;
      }
    } catch (_) {
      // ignore
    }

    await clearSession();
    return false;
  }

  // =====================================================
  // AUTH HEADER
  // =====================================================

  static Map<String, String> authHeader() {
    if (!isLoggedIn) return {};
    return {
      'Authorization': 'Bearer $_accessToken',
    };
  }

  // =====================================================
  // GUARDED REQUEST HELPER
  // =====================================================

  static Future<T> guarded<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      // token expired → try refresh once
      final ok = await refreshSession();
      if (!ok) rethrow;
      return await action();
    }
  }
}

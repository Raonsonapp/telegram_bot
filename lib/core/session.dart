/// lib/core/session.dart
/// =====================================================
/// SESSION MANAGER – FINAL (v5)
/// Handles auth state, token & user identity
/// =====================================================

import 'package:shared_preferences/shared_preferences.dart';

class Session {
  Session._();

  static SharedPreferences? _prefs;

  // =====================================================
  // INIT
  // =====================================================

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // =====================================================
  // TOKEN
  // =====================================================

  static Future<void> saveToken(String token) async {
    await _prefs?.setString('access_token', token);
  }

  static String? getToken() {
    return _prefs?.getString('access_token');
  }

  static Future<void> clearToken() async {
    await _prefs?.remove('access_token');
  }

  // =====================================================
  // USERNAME
  // =====================================================

  static Future<void> saveUsername(String username) async {
    await _prefs?.setString('username', username);
  }

  static String? getUsername() {
    return _prefs?.getString('username');
  }

  // =====================================================
  // LOGIN STATE
  // =====================================================

  static Future<bool> isLoggedIn() async {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  static Future<void> logout() async {
    await clearToken();
    await _prefs?.remove('username');
  }
}

/// =====================================================
/// TOKEN STORAGE – RAONSON CORE
/// Secure storage for auth tokens
/// =====================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage();

  // ================= KEYS =================
  static const String _accessTokenKey = 'raonson_access_token';
  static const String _refreshTokenKey = 'raonson_refresh_token';

  // ================= SAVE =================
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );
    await _storage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );
  }

  // ================= GET =================
  static Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  // ================= UPDATE ACCESS =================
  static Future<void> updateAccessToken(String token) async {
    await _storage.write(
      key: _accessTokenKey,
      value: token,
    );
  }

  // ================= CLEAR =================
  static Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // ================= EXISTS =================
  static Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

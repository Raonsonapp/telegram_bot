import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// =====================================================
/// TOKEN STORAGE
/// -----------------------------------------------------
/// Secure storage for:
/// - Access token
/// - Refresh token
/// - Token expiry
///
/// Uses flutter_secure_storage (Android Keystore / iOS Keychain)
/// =====================================================

class TokenStorage {
  TokenStorage._();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  // ================= KEYS =================
  static const String _kAccessToken = 'access_token';
  static const String _kRefreshToken = 'refresh_token';
  static const String _kExpiresAt = 'expires_at';

  // ================= ACCESS TOKEN =================
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _kAccessToken, value: token);
  }

  static Future<String?> getAccessToken() async {
    return _storage.read(key: _kAccessToken);
  }

  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: _kAccessToken);
  }

  // ================= REFRESH TOKEN =================
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _kRefreshToken, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _kRefreshToken);
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _kRefreshToken);
  }

  // ================= EXPIRY =================
  /// Save expiry as ISO8601 string
  static Future<void> saveExpiry(DateTime expiresAt) async {
    await _storage.write(
      key: _kExpiresAt,
      value: expiresAt.toIso8601String(),
    );
  }

  static Future<DateTime?> getExpiry() async {
    final raw = await _storage.read(key: _kExpiresAt);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static Future<void> deleteExpiry() async {
    await _storage.delete(key: _kExpiresAt);
  }

  // ================= HELPERS =================
  static Future<bool> hasAccessToken() async {
    final t = await getAccessToken();
    return t != null && t.isNotEmpty;
  }

  static Future<bool> isExpired({Duration leeway = const Duration(seconds: 30)}) async {
    final exp = await getExpiry();
    if (exp == null) return true;
    return DateTime.now().isAfter(exp.subtract(leeway));
  }

  // ================= CLEAR ALL =================
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

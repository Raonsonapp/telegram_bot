import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// =====================================================
/// CACHE MANAGER
/// -----------------------------------------------------
/// - Key-value persistent cache
/// - TTL (time-to-live) support
/// - Namespaced keys
/// - Safe JSON encode/decode
/// =====================================================
class CacheManager {
  CacheManager._internal();
  static final CacheManager instance = CacheManager._internal();

  static const String _ttlSuffix = '__ttl__';

  SharedPreferences? _prefs;

  /// Initialize once at app start
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _sp {
    if (_prefs == null) {
      throw StateError('CacheManager not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // =====================================================
  // BASIC SETTERS
  // =====================================================

  Future<void> setString(
    String key,
    String value, {
    Duration? ttl,
    String? namespace,
  }) async {
    final k = _k(key, namespace);
    await _sp.setString(k, value);
    _setTTL(k, ttl);
  }

  Future<void> setInt(
    String key,
    int value, {
    Duration? ttl,
    String? namespace,
  }) async {
    final k = _k(key, namespace);
    await _sp.setInt(k, value);
    _setTTL(k, ttl);
  }

  Future<void> setBool(
    String key,
    bool value, {
    Duration? ttl,
    String? namespace,
  }) async {
    final k = _k(key, namespace);
    await _sp.setBool(k, value);
    _setTTL(k, ttl);
  }

  Future<void> setDouble(
    String key,
    double value, {
    Duration? ttl,
    String? namespace,
  }) async {
    final k = _k(key, namespace);
    await _sp.setDouble(k, value);
    _setTTL(k, ttl);
  }

  Future<void> setJson(
    String key,
    Map<String, dynamic> value, {
    Duration? ttl,
    String? namespace,
  }) async {
    final k = _k(key, namespace);
    await _sp.setString(k, jsonEncode(value));
    _setTTL(k, ttl);
  }

  Future<void> setJsonList(
    String key,
    List<Map<String, dynamic>> value, {
    Duration? ttl,
    String? namespace,
  }) async {
    final k = _k(key, namespace);
    await _sp.setString(k, jsonEncode(value));
    _setTTL(k, ttl);
  }

  // =====================================================
  // BASIC GETTERS (WITH TTL CHECK)
  // =====================================================

  String? getString(String key, {String? namespace}) {
    final k = _k(key, namespace);
    if (_expired(k)) {
      _purge(k);
      return null;
    }
    return _sp.getString(k);
  }

  int? getInt(String key, {String? namespace}) {
    final k = _k(key, namespace);
    if (_expired(k)) {
      _purge(k);
      return null;
    }
    return _sp.getInt(k);
  }

  bool? getBool(String key, {String? namespace}) {
    final k = _k(key, namespace);
    if (_expired(k)) {
      _purge(k);
      return null;
    }
    return _sp.getBool(k);
  }

  double? getDouble(String key, {String? namespace}) {
    final k = _k(key, namespace);
    if (_expired(k)) {
      _purge(k);
      return null;
    }
    return _sp.getDouble(k);
  }

  Map<String, dynamic>? getJson(String key, {String? namespace}) {
    final k = _k(key, namespace);
    if (_expired(k)) {
      _purge(k);
      return null;
    }
    final raw = _sp.getString(k);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>>? getJsonList(
    String key, {
    String? namespace,
  }) {
    final k = _k(key, namespace);
    if (_expired(k)) {
      _purge(k);
      return null;
    }
    final raw = _sp.getString(k);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // =====================================================
  // TTL / EXPIRY
  // =====================================================

  void _setTTL(String key, Duration? ttl) {
    if (ttl == null) return;
    final expireAt = DateTime.now().add(ttl).millisecondsSinceEpoch;
    _sp.setInt('$key$_ttlSuffix', expireAt);
  }

  bool _expired(String key) {
    final ttlKey = '$key$_ttlSuffix';
    if (!_sp.containsKey(ttlKey)) return false;
    final expireAt = _sp.getInt(ttlKey);
    if (expireAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expireAt;
  }

  Future<void> extendTTL(
    String key,
    Duration ttl, {
    String? namespace,
  }) async {
    final k = _k(key, namespace);
    final expireAt =
        DateTime.now().add(ttl).millisecondsSinceEpoch;
    await _sp.setInt('$k$_ttlSuffix', expireAt);
  }

  // =====================================================
  // REMOVE / CLEAR
  // =====================================================

  Future<void> remove(String key, {String? namespace}) async {
    final k = _k(key, namespace);
    await _purge(k);
  }

  Future<void> clearNamespace(String namespace) async {
    final keys = _sp.getKeys().where(
          (k) => k.startsWith('$namespace:'),
        );
    for (final k in keys) {
      await _sp.remove(k);
    }
  }

  Future<void> clearAll() async {
    await _sp.clear();
  }

  Future<void> _purge(String key) async {
    await _sp.remove(key);
    await _sp.remove('$key$_ttlSuffix');
  }

  // =====================================================
  // HELPERS
  // =====================================================

  String _k(String key, String? namespace) {
    if (namespace == null || namespace.isEmpty) return key;
    return '$namespace:$key';
  }
}

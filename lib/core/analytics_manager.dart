import 'dart:async';
import 'package:flutter/foundation.dart';

/// =====================================================
/// ANALYTICS MANAGER (Raonson)
/// -----------------------------------------------------
/// Centralized analytics abstraction.
/// - App lifecycle events
/// - Screen tracking
/// - User actions (like, follow, post, reel, chat)
/// - Error & performance hooks
/// - Safe no-op in debug if not configured
/// =====================================================

enum AnalyticsEventType {
  screenView,
  action,
  auth,
  content,
  chat,
  notification,
  error,
  performance,
}

class AnalyticsEvent {
  final AnalyticsEventType type;
  final String name;
  final Map<String, dynamic> params;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.type,
    required this.name,
    Map<String, dynamic>? params,
    DateTime? timestamp,
  })  : params = params ?? const {},
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': describeEnum(type),
        'name': name,
        'params': params,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// =====================================================
/// AnalyticsAdapter
/// -----------------------------------------------------
/// Implement this interface to plug any provider:
/// - Firebase Analytics
/// - Segment
/// - Mixpanel
/// - Custom backend
/// =====================================================
abstract class AnalyticsAdapter {
  Future<void> init();
  Future<void> log(AnalyticsEvent event);
  Future<void> setUser({
    required String userId,
    String? username,
    bool? isVerified,
  });
  Future<void> clearUser();
}

/// =====================================================
/// DefaultAdapter (Safe No-Op)
/// -----------------------------------------------------
/// Used when no real analytics provider is attached.
/// =====================================================
class _NoOpAnalyticsAdapter implements AnalyticsAdapter {
  @override
  Future<void> init() async {}

  @override
  Future<void> log(AnalyticsEvent event) async {}

  @override
  Future<void> setUser({
    required String userId,
    String? username,
    bool? isVerified,
  }) async {}

  @override
  Future<void> clearUser() async {}
}

/// =====================================================
/// AnalyticsManager (Singleton)
/// =====================================================
class AnalyticsManager {
  AnalyticsManager._internal();

  static final AnalyticsManager _instance =
      AnalyticsManager._internal();

  factory AnalyticsManager() => _instance;

  AnalyticsAdapter _adapter = _NoOpAnalyticsAdapter();
  bool _initialized = false;
  bool _enabled = true;

  /// ---------------------------------------------------
  /// INIT
  /// ---------------------------------------------------
  Future<void> init({
    AnalyticsAdapter? adapter,
    bool enabled = true,
  }) async {
    _enabled = enabled;
    if (adapter != null) {
      _adapter = adapter;
    }
    await _adapter.init();
    _initialized = true;
  }

  /// ---------------------------------------------------
  /// USER
  /// ---------------------------------------------------
  Future<void> setUser({
    required String userId,
    String? username,
    bool? isVerified,
  }) async {
    if (!_canLog) return;
    await _adapter.setUser(
      userId: userId,
      username: username,
      isVerified: isVerified,
    );
  }

  Future<void> clearUser() async {
    if (!_canLog) return;
    await _adapter.clearUser();
  }

  /// ---------------------------------------------------
  /// SCREEN TRACKING
  /// ---------------------------------------------------
  Future<void> screen(String screenName,
      {Map<String, dynamic>? params}) async {
    await _log(
      AnalyticsEvent(
        type: AnalyticsEventType.screenView,
        name: screenName,
        params: params,
      ),
    );
  }

  /// ---------------------------------------------------
  /// ACTIONS
  /// ---------------------------------------------------
  Future<void> action(String name,
      {Map<String, dynamic>? params}) async {
    await _log(
      AnalyticsEvent(
        type: AnalyticsEventType.action,
        name: name,
        params: params,
      ),
    );
  }

  /// ---------------------------------------------------
  /// AUTH EVENTS
  /// ---------------------------------------------------
  Future<void> auth(String name,
      {Map<String, dynamic>? params}) async {
    await _log(
      AnalyticsEvent(
        type: AnalyticsEventType.auth,
        name: name,
        params: params,
      ),
    );
  }

  /// ---------------------------------------------------
  /// CONTENT (posts, reels, stories)
  /// ---------------------------------------------------
  Future<void> content(String name,
      {Map<String, dynamic>? params}) async {
    await _log(
      AnalyticsEvent(
        type: AnalyticsEventType.content,
        name: name,
        params: params,
      ),
    );
  }

  /// ---------------------------------------------------
  /// CHAT
  /// ---------------------------------------------------
  Future<void> chat(String name,
      {Map<String, dynamic>? params}) async {
    await _log(
      AnalyticsEvent(
        type: AnalyticsEventType.chat,
        name: name,
        params: params,
      ),
    );
  }

  /// ---------------------------------------------------
  /// NOTIFICATIONS
  /// ---------------------------------------------------
  Future<void> notification(String name,
      {Map<String, dynamic>? params}) async {
    await _log(
      AnalyticsEvent(
        type: AnalyticsEventType.notification,
        name: name,
        params: params,
      ),
    );
  }

  /// ---------------------------------------------------
  /// ERRORS
  /// ---------------------------------------------------
  Future<void> error(
    String name, {
    required String message,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) async {
    await _log(
      AnalyticsEvent(
        type: AnalyticsEventType.error,
        name: name,
        params: {
          'message': message,
          if (stackTrace != null) 'stack': stackTrace.toString(),
          if (extra != null) ...extra,
        },
      ),
    );
  }

  /// ---------------------------------------------------
  /// PERFORMANCE
  /// ---------------------------------------------------
  Future<void> performance(String name,
      {Map<String, dynamic>? params}) async {
    await _log(
      AnalyticsEvent(
        type: AnalyticsEventType.performance,
        name: name,
        params: params,
      ),
    );
  }

  /// ---------------------------------------------------
  /// INTERNAL LOGIC
  /// ---------------------------------------------------
  bool get _canLog =>
      _enabled && _initialized && !kDebugMode;

  Future<void> _log(AnalyticsEvent event) async {
    if (!_canLog) return;
    try {
      await _adapter.log(event);
    } catch (_) {
      // analytics must NEVER crash the app
    }
  }
}

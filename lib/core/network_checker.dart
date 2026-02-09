/// =====================================================
/// NETWORK CHECKER – RAONSON CORE
/// Handles connectivity & offline state
/// =====================================================

import 'dart:async';
import 'dart:io';

class NetworkChecker {
  NetworkChecker._();

  static final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  static bool _isOnline = true;
  static Timer? _timer;

  /// =====================================================
  /// PUBLIC STREAM
  /// =====================================================
  static Stream<bool> get onStatusChange => _controller.stream;

  static bool get isOnline => _isOnline;

  /// =====================================================
  /// START LISTENING
  /// =====================================================
  static void start({
    Duration interval = const Duration(seconds: 5),
  }) {
    _timer?.cancel();

    _timer = Timer.periodic(interval, (_) async {
      final status = await _checkConnection();
      if (status != _isOnline) {
        _isOnline = status;
        _controller.add(status);
      }
    });
  }

  /// =====================================================
  /// STOP
  /// =====================================================
  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// =====================================================
  /// MANUAL CHECK
  /// =====================================================
  static Future<bool> checkNow() async {
    final status = await _checkConnection();
    if (status != _isOnline) {
      _isOnline = status;
      _controller.add(status);
    }
    return status;
  }

  /// =====================================================
  /// INTERNAL CHECK
  /// =====================================================
  static Future<bool> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty &&
          result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// =====================================================
  /// DISPOSE
  /// =====================================================
  static void dispose() {
    stop();
    _controller.close();
  }
}

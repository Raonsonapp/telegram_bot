import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// NetworkChecker
/// ------------------------------------------------------------
/// - Checks internet connectivity
/// - Exposes stream for online/offline changes
/// - Simple helpers for UI & services
///
/// Usage:
/// final nc = NetworkChecker.instance;
/// await nc.isOnline();
/// nc.onStatusChanged.listen((online) { ... });
class NetworkChecker {
  NetworkChecker._internal() {
    _init();
  }

  static final NetworkChecker instance = NetworkChecker._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  bool _isOnline = true;
  StreamSubscription<ConnectivityResult>? _subscription;

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------
  Future<void> _init() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);
      _subscription =
          _connectivity.onConnectivityChanged.listen(_updateStatus);
    } catch (e) {
      debugPrint('NetworkChecker init error: $e');
      _setOnline(false);
    }
  }

  // ------------------------------------------------------------
  // STATUS HANDLING
  // ------------------------------------------------------------
  void _updateStatus(ConnectivityResult result) {
    final online = result != ConnectivityResult.none;
    _setOnline(online);
  }

  void _setOnline(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _statusController.add(_isOnline);
    }
  }

  // ------------------------------------------------------------
  // PUBLIC API
  // ------------------------------------------------------------

  /// Current online state
  bool get isCurrentlyOnline => _isOnline;

  /// Future check (useful before API calls)
  Future<bool> isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);
      return _isOnline;
    } catch (_) {
      _setOnline(false);
      return false;
    }
  }

  /// Stream of online/offline changes
  Stream<bool> get onStatusChanged => _statusController.stream;

  // ------------------------------------------------------------
  // CLEANUP
  // ------------------------------------------------------------
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _statusController.close();
  }
}

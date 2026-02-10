import 'dart:async';
import 'package:flutter/material.dart';

import '../core/session_manager.dart';
import '../core/network_checker.dart';
import '../core/error_handler.dart';
import 'app_state.dart';
import 'app_routes.dart';

/// =====================================================
/// AppController
/// -----------------------------------------------------
/// Global application controller:
/// - App lifecycle
/// - Auth/session bootstrap
/// - Network status
/// - Global loading & error handling
/// - Navigation helpers
/// =====================================================
class AppController extends ChangeNotifier {
  AppController({
    required SessionManager sessionManager,
    required NetworkChecker networkChecker,
  })  : _sessionManager = sessionManager,
        _networkChecker = networkChecker {
    _init();
  }

  // ================= DEPENDENCIES =================
  final SessionManager _sessionManager;
  final NetworkChecker _networkChecker;

  // ================= STATE =================
  AppState _state = const AppState.initial();
  AppState get state => _state;

  bool _initialized = false;
  bool get initialized => _initialized;

  bool _hasNetwork = true;
  bool get hasNetwork => _hasNetwork;

  StreamSubscription<bool>? _networkSub;
  StreamSubscription<SessionStatus>? _sessionSub;

  // ================= INIT =================
  Future<void> _init() async {
    try {
      _setState(_state.copyWith(loading: true));

      // --- Listen network changes
      _hasNetwork = await _networkChecker.hasConnection();
      _networkSub =
          _networkChecker.onStatusChange.listen(_onNetworkChanged);

      // --- Listen session changes
      _sessionSub =
          _sessionManager.onStatusChanged.listen(_onSessionChanged);

      // --- Restore session
      await _sessionManager.restoreSession();

      _initialized = true;
      _setState(_state.copyWith(loading: false));
    } catch (e, s) {
      ErrorHandler.log(e, s);
      _setState(
        _state.copyWith(
          loading: false,
          error: 'Failed to initialize app',
        ),
      );
    }
  }

  // ================= NETWORK =================
  void _onNetworkChanged(bool connected) {
    _hasNetwork = connected;
    notifyListeners();
  }

  // ================= SESSION =================
  void _onSessionChanged(SessionStatus status) {
    switch (status) {
      case SessionStatus.authenticated:
        _setState(
          _state.copyWith(
            isAuthenticated: true,
            user: _sessionManager.currentUser,
          ),
        );
        break;

      case SessionStatus.unauthenticated:
        _setState(
          _state.copyWith(
            isAuthenticated: false,
            user: null,
          ),
        );
        break;

      case SessionStatus.expired:
        logout();
        break;
    }
  }

  // ================= AUTH ACTIONS =================
  Future<void> logout() async {
    try {
      _setState(_state.copyWith(loading: true));
      await _sessionManager.clearSession();
      _setState(
        _state.copyWith(
          loading: false,
          isAuthenticated: false,
          user: null,
        ),
      );
    } catch (e, s) {
      ErrorHandler.log(e, s);
      _setState(
        _state.copyWith(
          loading: false,
          error: 'Logout failed',
        ),
      );
    }
  }

  // ================= NAVIGATION =================
  /// Returns initial route based on auth state
  String getInitialRoute() {
    if (!_initialized) return AppRoutes.splash;
    return _state.isAuthenticated
        ? AppRoutes.home
        : AppRoutes.login;
  }

  /// Global guarded navigation
  bool canAccessProtectedRoute() {
    return _state.isAuthenticated;
  }

  // ================= HELPERS =================
  void clearError() {
    if (_state.error != null) {
      _setState(_state.copyWith(error: null));
    }
  }

  void setGlobalLoading(bool value) {
    _setState(_state.copyWith(loading: value));
  }

  void _setState(AppState newState) {
    _state = newState;
    notifyListeners();
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    _networkSub?.cancel();
    _sessionSub?.cancel();
    super.dispose();
  }
}

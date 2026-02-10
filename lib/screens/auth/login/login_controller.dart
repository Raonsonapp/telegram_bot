// lib/screens/auth/login/login_controller.dart

import 'package:flutter/material.dart';

import '../../../core/session_manager.dart';
import '../../../core/error_handler.dart';
import '../../../core/network_checker.dart';
import '../../../auth/auth_service.dart';

class LoginController extends ChangeNotifier {
  LoginController({
    required AuthService authService,
    required SessionManager sessionManager,
    required NetworkChecker networkChecker,
  })  : _authService = authService,
        _sessionManager = sessionManager,
        _networkChecker = networkChecker;

  final AuthService _authService;
  final SessionManager _sessionManager;
  final NetworkChecker _networkChecker;

  bool _loading = false;
  String? _error;

  bool get isLoading => _loading;
  String? get error => _error;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setError(null);

    final hasInternet = await _networkChecker.hasConnection();
    if (!hasInternet) {
      _setError('No internet connection');
      return false;
    }

    _setLoading(true);

    try {
      final result = await _authService.login(
        username: username.trim(),
        password: password,
      );

      await _sessionManager.saveSession(
        token: result.token,
        user: result.user,
      );

      return true;
    } catch (e, s) {
      _setError(ErrorHandler.parse(e, s));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _sessionManager.clearSession();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}

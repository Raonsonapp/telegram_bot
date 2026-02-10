import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../core/error_handler.dart';

class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController(this._authService);

  final AuthService _authService;

  bool _loading = false;
  String? _error;
  bool _success = false;

  bool get loading => _loading;
  String? get error => _error;
  bool get success => _success;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void _setSuccess(bool v) {
    _success = v;
    notifyListeners();
  }

  /// Send reset link / code to email or phone
  Future<void> submit({
    required String identifier, // email or phone
  }) async {
    if (identifier.trim().isEmpty) {
      _setError('Email or phone is required');
      return;
    }

    _setError(null);
    _setSuccess(false);
    _setLoading(true);

    try {
      await _authService.forgotPassword(identifier: identifier.trim());
      _setSuccess(true);
    } catch (e) {
      _setError(ErrorHandler.message(e));
    } finally {
      _setLoading(false);
    }
  }

  void reset() {
    _error = null;
    _success = false;
    _loading = false;
    notifyListeners();
  }
}

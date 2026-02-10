import 'package:flutter/material.dart';

import '../../../core/error_handler.dart';
import '../../../core/session_manager.dart';
import '../../../services/auth_service.dart';
import 'register_state.dart';
import 'register_validator.dart';

class RegisterController extends ChangeNotifier {
  RegisterController(this._authService);

  final AuthService _authService;

  RegisterState _state = const RegisterState();
  RegisterState get state => _state;

  // ========================
  // UPDATE STATE
  // ========================
  void _setState(RegisterState newState) {
    _state = newState;
    notifyListeners();
  }

  // ========================
  // FIELD UPDATES
  // ========================
  void updateUsername(String value) {
    _setState(_state.copyWith(username: value, error: null));
  }

  void updateEmail(String value) {
    _setState(_state.copyWith(email: value, error: null));
  }

  void updatePassword(String value) {
    _setState(_state.copyWith(password: value, error: null));
  }

  void updateConfirmPassword(String value) {
    _setState(_state.copyWith(confirmPassword: value, error: null));
  }

  // ========================
  // REGISTER
  // ========================
  Future<bool> register() async {
    final validationError = RegisterValidator.validate(
      username: _state.username,
      email: _state.email,
      password: _state.password,
      confirmPassword: _state.confirmPassword,
    );

    if (validationError != null) {
      _setState(_state.copyWith(error: validationError));
      return false;
    }

    _setState(_state.copyWith(loading: true, error: null));

    try {
      final result = await _authService.register(
        username: _state.username.trim(),
        email: _state.email.trim(),
        password: _state.password,
      );

      // save session/token if backend returns it
      if (result.token != null) {
        await SessionManager.saveToken(result.token!);
      }

      _setState(_state.copyWith(loading: false, success: true));
      return true;
    } catch (e) {
      final message = ErrorHandler.parse(e);
      _setState(_state.copyWith(loading: false, error: message));
      return false;
    }
  }

  // ========================
  // RESET
  // ========================
  void reset() {
    _setState(const RegisterState());
  }
}

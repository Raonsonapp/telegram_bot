import 'dart:async';

import '../../auth_service.dart';
import 'login_state.dart';

/// =====================================================
/// LOGIN CONTROLLER – Raonson
/// -----------------------------------------------------
/// Handles:
/// - Login request
/// - Loading / success / error states
/// - Token & session handled in AuthService
/// =====================================================

class LoginController {
  final _stateController = StreamController<LoginState>.broadcast();

  Stream<LoginState> get state => _stateController.stream;

  LoginState _current = const LoginState.initial();

  void _emit(LoginState state) {
    _current = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  /// ================= LOGIN =================
  Future<void> login({
    required String username,
    required String password,
  }) async {
    if (_current.isLoading) return;

    _emit(const LoginState.loading());

    try {
      await AuthService.login(
        username: username,
        password: password,
      );

      _emit(const LoginState.success());
    } catch (e) {
      _emit(
        LoginState.error(
          e.toString().replaceFirst('Exception:', '').trim(),
        ),
      );
    }
  }

  /// ================= DISPOSE =================
  void dispose() {
    _stateController.close();
  }
}

import 'package:flutter/foundation.dart';

/// LoginState
/// ------------------------------------------------------------
/// Holds UI + business state for Login screen
/// Pure state object (immutable pattern)
///
/// Used by:
/// - LoginController
/// - LoginScreen
///
/// Version: v1 (Raonson)
@immutable
class LoginState {
  // =========================
  // FORM FIELDS
  // =========================
  final String username;
  final String password;

  // =========================
  // UI STATES
  // =========================
  final bool isLoading;
  final bool isPasswordVisible;

  // =========================
  // ERROR / STATUS
  // =========================
  final String? errorMessage;

  // =========================
  // SUCCESS
  // =========================
  final bool isSuccess;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================
  const LoginState({
    this.username = '',
    this.password = '',
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  // ============================================================
  // INITIAL STATE
  // ============================================================
  factory LoginState.initial() {
    return const LoginState();
  }

  // ============================================================
  // COPY WITH (IMMUTABLE UPDATE)
  // ============================================================
  LoginState copyWith({
    String? username,
    String? password,
    bool? isLoading,
    bool? isPasswordVisible,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible:
          isPasswordVisible ?? this.isPasswordVisible,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  bool get hasError =>
      errorMessage != null && errorMessage!.isNotEmpty;

  bool get canSubmit =>
      username.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
      !isLoading;

  @override
  String toString() {
    return 'LoginState('
        'username: $username, '
        'isLoading: $isLoading, '
        'isSuccess: $isSuccess, '
        'error: $errorMessage'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoginState &&
        other.username == username &&
        other.password == password &&
        other.isLoading == isLoading &&
        other.isPasswordVisible == isPasswordVisible &&
        other.errorMessage == errorMessage &&
        other.isSuccess == isSuccess;
  }

  @override
  int get hashCode {
    return Object.hash(
      username,
      password,
      isLoading,
      isPasswordVisible,
      errorMessage,
      isSuccess,
    );
  }
}

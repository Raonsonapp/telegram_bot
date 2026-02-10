// lib/screens/auth/register/register_state.dart

import 'package:flutter/material.dart';

@immutable
class RegisterState {
  // =========================
  // FORM FIELDS
  // =========================
  final String username;
  final String email;
  final String password;
  final String confirmPassword;

  // =========================
  // UI STATES
  // =========================
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  // =========================
  // CONSTRUCTOR
  // =========================
  const RegisterState({
    this.username = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  // =========================
  // COPY WITH
  // =========================
  RegisterState copyWith({
    String? username,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return RegisterState(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  // =========================
  // HELPERS
  // =========================
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isFormValid =>
      username.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      password == confirmPassword;

  // =========================
  // INITIAL STATE
  // =========================
  static const RegisterState initial = RegisterState();

  @override
  String toString() {
    return 'RegisterState(username: $username, email: $email, loading: $isLoading, success: $isSuccess)';
  }
}

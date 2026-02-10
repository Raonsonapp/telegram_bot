// lib/screens/auth/forgot_password/forgot_password_state.dart
// =====================================================
// FORGOT PASSWORD STATE – Raonson v1
// Fully self-contained, no missing fields
// Used by: forgot_password_controller.dart
// =====================================================

enum ForgotPasswordStatus {
  idle,
  loading,
  success,
  error,
}

class ForgotPasswordState {
  final ForgotPasswordStatus status;
  final String email;
  final String message; // success or error message
  final bool isButtonEnabled;

  const ForgotPasswordState({
    required this.status,
    required this.email,
    required this.message,
    required this.isButtonEnabled,
  });

  // ================= INITIAL =================
  factory ForgotPasswordState.initial() {
    return const ForgotPasswordState(
      status: ForgotPasswordStatus.idle,
      email: '',
      message: '',
      isButtonEnabled: false,
    );
  }

  // ================= COPY WITH =================
  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? email,
    String? message,
    bool? isButtonEnabled,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      message: message ?? this.message,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
    );
  }

  // ================= HELPERS =================
  bool get isLoading => status == ForgotPasswordStatus.loading;
  bool get isSuccess => status == ForgotPasswordStatus.success;
  bool get isError => status == ForgotPasswordStatus.error;

  @override
  String toString() {
    return 'ForgotPasswordState(status: $status, email: $email, message: $message)';
  }
}

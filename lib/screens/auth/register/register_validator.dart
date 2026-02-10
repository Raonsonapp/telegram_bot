/// =====================================================
/// RegisterValidator
/// Validates all inputs for Register flow
/// Safe • Reusable • Centralized
/// =====================================================

class RegisterValidator {
  /// -------------------------------
  /// Username
  /// -------------------------------
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    final username = value.trim();

    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (username.length > 20) {
      return 'Username must be less than 20 characters';
    }

    final regex = RegExp(r'^[a-zA-Z0-9._]+$');
    if (!regex.hasMatch(username)) {
      return 'Only letters, numbers, . and _ allowed';
    }

    return null;
  }

  /// -------------------------------
  /// Email
  /// -------------------------------
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    final regex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!regex.hasMatch(email)) {
      return 'Invalid email address';
    }

    return null;
  }

  /// -------------------------------
  /// Phone (optional)
  /// -------------------------------
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // optional
    }

    final phone = value.trim();

    final regex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!regex.hasMatch(phone)) {
      return 'Invalid phone number';
    }

    return null;
  }

  /// -------------------------------
  /// Password
  /// -------------------------------
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }

    return null;
  }

  /// -------------------------------
  /// Confirm Password
  /// -------------------------------
  static String? validateConfirmPassword(
    String? value,
    String password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// -------------------------------
  /// Agreement checkbox
  /// -------------------------------
  static String? validateAgreement(bool accepted) {
    if (!accepted) {
      return 'You must accept the terms';
    }
    return null;
  }
}

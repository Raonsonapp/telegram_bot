/// lib/utils/validators.dart
/// Central validators for Raonson App
/// Version: v5 (Full Social Network)

class Validators {
  Validators._();

  // ================= EMAIL =================
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email required';
    }

    final emailRegex = RegExp(
      r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email format';
    }

    return null;
  }

  // ================= PHONE =================
  /// Accepts:
  /// +992xxxxxxxxx
  /// 992xxxxxxxxx
  /// xxxxxxxxx
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number required';
    }

    final cleaned = value.replaceAll(' ', '');

    final phoneRegex = RegExp(r'^(\+?992)?\d{9}$');

    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Invalid phone number';
    }

    return null;
  }

  // ================= USERNAME =================
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username required';
    }

    if (value.length < 3) {
      return 'Username too short';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_.]+$');

    if (!usernameRegex.hasMatch(value)) {
      return 'Only letters, numbers, _ and . allowed';
    }

    return null;
  }

  // ================= PASSWORD =================
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // ================= CONFIRM PASSWORD =================
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }

    if (value != original) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ================= BIO =================
  static String? bio(String? value) {
    if (value == null) return null;

    if (value.length > 150) {
      return 'Bio too long (max 150)';
    }

    return null;
  }

  // ================= SEARCH =================
  static String? search(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Search cannot be empty';
    }

    if (value.length < 2) {
      return 'Enter at least 2 characters';
    }

    return null;
  }

  // ================= OTP CODE =================
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Code required';
    }

    final otpRegex = RegExp(r'^\d{6}$');

    if (!otpRegex.hasMatch(value)) {
      return 'Invalid 6-digit code';
    }

    return null;
  }
}

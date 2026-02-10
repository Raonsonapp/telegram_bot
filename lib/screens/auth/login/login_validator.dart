/// =====================================================
/// LOGIN VALIDATOR – FULL
/// File: lib/screens/auth/login/login_validator.dart
/// Purpose:
/// - Validate login form fields
/// - Username / email / phone validation
/// - Password rules
/// =====================================================

class LoginValidator {
  // =========================
  // USERNAME / EMAIL / PHONE
  // =========================

  static String? validateIdentity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username, email or phone is required';
    }

    final v = value.trim();

    // email
    if (_isEmail(v)) return null;

    // phone
    if (_isPhone(v)) return null;

    // username
    if (_isUsername(v)) return null;

    return 'Enter a valid username, email or phone';
  }

  // =========================
  // PASSWORD
  // =========================

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (value.length > 64) {
      return 'Password is too long';
    }

    return null;
  }

  // =========================
  // HELPERS
  // =========================

  static bool _isEmail(String v) {
    final emailReg =
        RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$');
    return emailReg.hasMatch(v);
  }

  static bool _isPhone(String v) {
    final phoneReg = RegExp(r'^\+?[0-9]{7,15}$');
    return phoneReg.hasMatch(v);
  }

  static bool _isUsername(String v) {
    final userReg =
        RegExp(r'^[a-zA-Z0-9_.]{3,30}$');
    return userReg.hasMatch(v);
  }
}

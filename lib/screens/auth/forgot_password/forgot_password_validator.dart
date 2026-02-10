/// =====================================================
/// Forgot Password Validator – Raonson v5
/// Responsible for validating inputs for:
/// - Forgot password
/// - Email / phone based recovery
/// =====================================================

class ForgotPasswordValidator {
  ForgotPasswordValidator._();

  // =====================================================
  // EMAIL VALIDATION
  // =====================================================

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    // Basic email regex (safe & production-ready)
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z0-9]"
      r"(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // =====================================================
  // PHONE VALIDATION
  // =====================================================

  /// Validates phone number (international, digits only)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phone = value.trim().replaceAll(' ', '');

    // Allow + and digits, min 7, max 15
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

    if (!phoneRegex.hasMatch(phone)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  // =====================================================
  // USERNAME VALIDATION (OPTIONAL FLOW)
  // =====================================================

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    final username = value.trim();

    if (username.length < 3) {
      return 'Username is too short';
    }

    if (username.length > 30) {
      return 'Username is too long';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9._]+$');

    if (!usernameRegex.hasMatch(username)) {
      return 'Only letters, numbers, dot and underscore allowed';
    }

    return null;
  }

  // =====================================================
  // RECOVERY TYPE CHECK
  // =====================================================

  /// Ensures at least one recovery field is provided
  static String? validateRecoveryInput({
    String? email,
    String? phone,
    String? username,
  }) {
    final hasEmail = email != null && email.trim().isNotEmpty;
    final hasPhone = phone != null && phone.trim().isNotEmpty;
    final hasUsername = username != null && username.trim().isNotEmpty;

    if (!hasEmail && !hasPhone && !hasUsername) {
      return 'Provide email, phone, or username';
    }

    return null;
  }

  // =====================================================
  // FINAL FORM VALIDATION
  // =====================================================

  /// Full validation before submit
  static Map<String, String> validateAll({
    String? email,
    String? phone,
    String? username,
  }) {
    final errors = <String, String>{};

    final recoveryError = validateRecoveryInput(
      email: email,
      phone: phone,
      username: username,
    );

    if (recoveryError != null) {
      errors['general'] = recoveryError;
      return errors;
    }

    if (email != null && email.trim().isNotEmpty) {
      final e = validateEmail(email);
      if (e != null) errors['email'] = e;
    }

    if (phone != null && phone.trim().isNotEmpty) {
      final p = validatePhone(phone);
      if (p != null) errors['phone'] = p;
    }

    if (username != null && username.trim().isNotEmpty) {
      final u = validateUsername(username);
      if (u != null) errors['username'] = u;
    }

    return errors;
  }
}

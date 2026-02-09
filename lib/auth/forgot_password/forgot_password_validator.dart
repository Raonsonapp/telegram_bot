import '../../utils/validators.dart';

class ForgotPasswordValidator {
  static String? email(String? value) => Validators.email(value);
}

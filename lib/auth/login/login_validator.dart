import '../../utils/validators.dart';

class LoginValidator {
  static String? email(String? value) => Validators.email(value);
  static String? password(String? value) => Validators.password(value);
}

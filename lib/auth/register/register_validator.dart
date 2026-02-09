import '../../utils/validators.dart';

class RegisterValidator {
  static String? name(String? value) => Validators.required(value, 'Name');
  static String? email(String? value) => Validators.email(value);
  static String? password(String? value) => Validators.password(value);
}

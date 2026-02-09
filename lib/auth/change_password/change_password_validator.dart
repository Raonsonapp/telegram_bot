import '../../utils/validators.dart';

class ChangePasswordValidator {
  static String? password(String? value) => Validators.password(value);
}

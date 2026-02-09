import '../../utils/validators.dart';

class EditProfileValidator {
  static String? name(String? value) => Validators.required(value, 'Name');
}

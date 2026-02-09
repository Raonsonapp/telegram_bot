import 'package:flutter/foundation.dart';

class EditProfileController extends ChangeNotifier {
  bool _saved = false;

  bool get saved => _saved;

  Future<void> saveProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _saved = true;
    notifyListeners();
  }
}

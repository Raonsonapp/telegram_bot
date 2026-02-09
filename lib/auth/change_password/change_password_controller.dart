import 'package:flutter/foundation.dart';

class ChangePasswordController extends ChangeNotifier {
  bool _updated = false;

  bool get updated => _updated;

  Future<void> updatePassword(String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _updated = true;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

class VerifyEmailController extends ChangeNotifier {
  bool _verified = false;

  bool get verified => _verified;

  Future<void> verifyCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _verified = true;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

class ForgotPasswordController extends ChangeNotifier {
  bool _sent = false;

  bool get sent => _sent;

  Future<void> sendReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _sent = true;
    notifyListeners();
  }
}

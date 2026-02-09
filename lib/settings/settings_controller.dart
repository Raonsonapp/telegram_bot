import 'package:flutter/foundation.dart';

class SettingsController extends ChangeNotifier {
  bool notificationsEnabled = true;
  bool privateAccount = false;

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void togglePrivate(bool value) {
    privateAccount = value;
    notifyListeners();
  }
}

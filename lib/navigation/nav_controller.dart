import 'package:flutter/foundation.dart';

class NavController extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void updateIndex(int value) {
    _index = value;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

import 'token_storage.dart';

class SessionManager extends ChangeNotifier {
  SessionManager({TokenStorage? storage})
      : _storage = storage ?? TokenStorage();

  final TokenStorage _storage;
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    _token = await _storage.getToken();
    notifyListeners();
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.saveToken(token);
    notifyListeners();
  }

  Future<void> clearSession() async {
    _token = null;
    await _storage.clearToken();
    notifyListeners();
  }
}

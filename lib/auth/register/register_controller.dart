import 'package:flutter/foundation.dart';

import '../../core/error_handler.dart';
import '../../core/session_manager.dart';
import '../auth_repository.dart';

class RegisterController extends ChangeNotifier {
  RegisterController(this._repository, this._sessionManager);

  final AuthRepository _repository;
  final SessionManager _sessionManager;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      final token = await _repository.register(name, email, password);
      if (token.isNotEmpty) {
        await _sessionManager.setToken(token);
      } else {
        _error = 'Unable to register';
      }
    } catch (error) {
      _error = ErrorHandler.message(error);
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}

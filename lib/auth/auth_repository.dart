import '../core/http_client.dart';

import 'auth_service.dart';

class AuthRepository {
  AuthRepository({HttpClient? client})
      : _service = AuthService(client ?? HttpClient());

  final AuthService _service;

  Future<String> login(String email, String password) async {
    final response = await _service.login(email: email, password: password);
    return response['token']?.toString() ?? '';
  }

  Future<String> register(String name, String email, String password) async {
    final response = await _service.register(
      name: name,
      email: email,
      password: password,
    );
    return response['token']?.toString() ?? '';
  }
}

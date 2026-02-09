import '../core/http_client.dart';

class AuthService {
  AuthService(this._client);

  final HttpClient _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}

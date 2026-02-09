/// lib/services/auth_service.dart
/// =====================================================
/// AUTH SERVICE – FINAL v5
/// Handles:
/// - Login
/// - Register
/// - Logout
/// - Get current user
/// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';
import '../core/session.dart';
import '../models/user.dart';

class AuthService {
  // =====================================================
  // LOGIN
  // =====================================================

  static Future<User> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final response = await HttpService.post(
      Api.login,
      body: {
        'login': emailOrUsername,
        'password': password,
      },
      auth: false,
    );

    final token = response['access_token'];
    final userJson = response['user'];

    if (token == null || userJson == null) {
      throw Exception('Invalid login response');
    }

    await Session.saveToken(token);

    return User.fromJson(userJson);
  }

  // =====================================================
  // REGISTER
  // =====================================================

  static Future<User> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await HttpService.post(
      Api.register,
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
      auth: false,
    );

    final token = response['access_token'];
    final userJson = response['user'];

    if (token == null || userJson == null) {
      throw Exception('Invalid register response');
    }

    await Session.saveToken(token);

    return User.fromJson(userJson);
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  static Future<void> logout() async {
    try {
      await HttpService.post(
        Api.logout,
        body: {},
        auth: true,
      );
    } catch (_) {
      // ignore backend failure
    } finally {
      await Session.clear();
    }
  }

  // =====================================================
  // CURRENT USER
  // =====================================================

  static Future<User> me() async {
    final response = await HttpService.get(
      Api.me,
      auth: true,
    );

    return User.fromJson(response);
  }
}

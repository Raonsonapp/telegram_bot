/// lib/services/auth_service.dart
/// =====================================================
/// AUTH SERVICE – FINAL v5 (FIXED)
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
    final res = await HttpService.post(
      Api.login,
      body: {
        'login': emailOrUsername,
        'password': password,
      },
      auth: false,
    );

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid login response format');
    }

    final token = res['access_token'];
    final userJson = res['user'];

    if (token is! String || userJson is! Map<String, dynamic>) {
      throw Exception('Invalid login response data');
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
    final res = await HttpService.post(
      Api.register,
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
      auth: false,
    );

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid register response format');
    }

    final token = res['access_token'];
    final userJson = res['user'];

    if (token is! String || userJson is! Map<String, dynamic>) {
      throw Exception('Invalid register response data');
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
      // backend failure ignored
    } finally {
      await Session.clearSession();
    }
  }

  // =====================================================
  // CURRENT USER
  // =====================================================

  static Future<User> me() async {
    final token = await Session.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final res = await HttpService.get(
      Api.me,
      auth: true,
    );

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid user response');
    }

    return User.fromJson(res);
  }
}

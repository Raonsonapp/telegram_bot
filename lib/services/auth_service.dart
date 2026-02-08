import '../core/api.dart';
import '../core/http_service.dart';
import '../core/session.dart';
import '../models/user.dart';

class AuthService {
  // ================= LOGIN =================
  static Future<User> login({
    required String identifier, // username | email | phone
    required String password,
  }) async {
    final res = await HttpService.post(
      Api.loginEndpoint,
      {
        'identifier': identifier,
        'password': password,
      },
    );

    if (res == null || res['token'] == null) {
      throw Exception('Login failed');
    }

    // Save session
    await Session.saveToken(res['token']);
    await Session.saveUser(res['user']);

    return User.fromJson(res['user']);
  }

  // ================= REGISTER =================
  static Future<User> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await HttpService.post(
      Api.registerEndpoint,
      {
        'username': username,
        'email': email,
        'password': password,
      },
    );

    if (res == null || res['token'] == null) {
      throw Exception('Registration failed');
    }

    // Save session
    await Session.saveToken(res['token']);
    await Session.saveUser(res['user']);

    return User.fromJson(res['user']);
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    try {
      await HttpService.post(Api.logoutEndpoint, {});
    } catch (_) {
      // ignore server error on logout
    }

    await Session.clearSession();
  }

  // ================= REFRESH TOKEN =================
  static Future<bool> refreshToken() async {
    final token = await Session.getToken();
    if (token == null) return false;

    try {
      final res = await HttpService.post(
        Api.refreshTokenEndpoint,
        {'token': token},
      );

      if (res == null || res['token'] == null) return false;

      await Session.saveToken(res['token']);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ================= CURRENT USER =================
  static Future<User?> getCurrentUser() async {
    final data = await Session.getUser();
    if (data == null) return null;
    return User.fromJson(data);
  }

  // ================= AUTH STATE =================
  static Future<bool> isLoggedIn() async {
    return await Session.isLoggedIn();
  }
}

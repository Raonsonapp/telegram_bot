import '../core/api.dart';
import '../core/http_service.dart';
import '../core/session.dart';

class AuthService {
  // ===== LOGIN =====
  static Future<bool> login({
    required String identifier, // phone OR email OR username
    required String password,
  }) async {
    final res = await HttpService.post(
      Api.loginEndpoint,
      {
        'identifier': identifier,
        'password': password,
      },
    );

    if (res != null && res['token'] != null) {
      await Session.saveToken(res['token']);
      return true;
    }
    return false;
  }

  // ===== REGISTER =====
  static Future<bool> register({
    required String username,
    required String phone,
    required String password,
  }) async {
    final res = await HttpService.post(
      Api.registerEndpoint,
      {
        'username': username,
        'phone': phone,
        'password': password,
      },
    );

    if (res != null && res['token'] != null) {
      await Session.saveToken(res['token']);
      return true;
    }
    return false;
  }

  // ===== LOGOUT =====
  static Future<void> logout() async {
    await Session.clearSession();
  }

  // ===== CHECK AUTH =====
  static Future<bool> isLoggedIn() async {
    return await Session.isLoggedIn();
  }
}

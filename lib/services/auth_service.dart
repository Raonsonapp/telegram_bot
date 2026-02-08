import '../core/api.dart';
import '../core/http_service.dart';
import '../core/session.dart';
import '../models/user.dart';

class AuthService {
  // ================= LOGIN =================
  static Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await HttpService.post(
      Api.loginEndpoint,
      {
        'username': username,
        'password': password,
      },
    );

    final token = response['token'];
    final userJson = response['user'];

    if (token == null || userJson == null) {
      throw Exception('Invalid login response');
    }

    await Session.saveToken(token);

    return UserModel.fromJson(userJson);
  }

  // ================= REGISTER =================
  static Future<UserModel> register({
    required String username,
    required String password,
  }) async {
    final response = await HttpService.post(
      Api.registerEndpoint,
      {
        'username': username,
        'password': password,
      },
    );

    final token = response['token'];
    final userJson = response['user'];

    if (token == null || userJson == null) {
      throw Exception('Invalid register response');
    }

    await Session.saveToken(token);

    return UserModel.fromJson(userJson);
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    try {
      await HttpService.post(Api.logoutEndpoint, {});
    } catch (_) {
      // ҳатто агар сервер ҷавоб надиҳад ҳам, сессия тоза мешавад
    }

    await Session.clearSession();
  }

  // ================= CURRENT USER =================
  static Future<UserModel?> getCurrentUser() async {
    final token = await Session.getToken();
    if (token == null) return null;

    try {
      final response = await HttpService.get(Api.meEndpoint);
      return UserModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }
}

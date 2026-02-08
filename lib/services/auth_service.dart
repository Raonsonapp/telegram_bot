import '../core/session.dart';

class AuthService {
  static Future<void> login(String username, String password) async {
    // Ҳоло mock (сервер дар қадами дигар)
    await Future.delayed(const Duration(seconds: 1));

    if (username.isEmpty || password.isEmpty) {
      throw Exception("Invalid credentials");
    }

    await Session.save("fake_token_123", username);
  }

  static Future<void> register(
      String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (username.length < 3 || password.length < 4) {
      throw Exception("Invalid data");
    }

    await Session.save("fake_token_123", username);
  }

  static Future<void> logout() async {
    await Session.logout();
  }
}

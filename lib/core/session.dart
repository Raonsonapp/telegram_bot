import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _tokenKey = 'token';
  static const _usernameKey = 'username';

  static Future<void> save(String token, String username) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_tokenKey, token);
    await p.setString(_usernameKey, username);
  }

  static Future<String?> token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_tokenKey);
  }

  static Future<String?> username() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_usernameKey);
  }

  static Future<bool> isLoggedIn() async {
    final t = await token();
    return t != null && t.isNotEmpty;
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
  }
}

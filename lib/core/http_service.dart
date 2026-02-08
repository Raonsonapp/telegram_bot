import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpService {
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<dynamic> get(String url, {bool auth = true}) async {
    final res = await http.get(
      Uri.parse(url),
      headers: await _headers(auth: auth),
    );
    return _handleResponse(res);
  }

  static Future<dynamic> post(
    String url,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final res = await http.post(
      Uri.parse(url),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  static Future<dynamic> put(
    String url,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final res = await http.put(
      Uri.parse(url),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  static Future<dynamic> delete(String url, {bool auth = true}) async {
    final res = await http.delete(
      Uri.parse(url),
      headers: await _headers(auth: auth),
    );
    return _handleResponse(res);
  }

  static dynamic _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}

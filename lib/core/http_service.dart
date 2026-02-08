import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpService {
  static const Duration _timeout = Duration(seconds: 20);

  // ================= HEADERS =================
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ================= TOKEN =================
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ================= GET =================
  static Future<dynamic> get(
    String url, {
    bool auth = true,
  }) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: await _headers(auth: auth))
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw 'No internet connection';
    } on HttpException {
      throw 'Server error';
    } on FormatException {
      throw 'Bad response format';
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= POST =================
  static Future<dynamic> post(
    String url,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw 'No internet connection';
    } on HttpException {
      throw 'Server error';
    } on FormatException {
      throw 'Bad response format';
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= PUT =================
  static Future<dynamic> put(
    String url,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw 'No internet connection';
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= DELETE =================
  static Future<dynamic> delete(
    String url, {
    bool auth = true,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse(url),
            headers: await _headers(auth: auth),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw 'No internet connection';
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= RESPONSE HANDLER =================
  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (response.body.isEmpty) {
      return null;
    }

    final data = jsonDecode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return data;
    }

    if (statusCode == 401) {
      throw 'Unauthorized. Please login again.';
    }

    if (statusCode == 403) {
      throw 'Access denied';
    }

    if (statusCode == 404) {
      throw 'Resource not found';
    }

    if (statusCode >= 500) {
      throw 'Server error. Try again later.';
    }

    throw data['message'] ?? 'Unknown error';
  }
}

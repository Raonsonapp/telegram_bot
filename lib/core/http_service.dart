/// lib/core/http_service.dart
/// =====================================================
/// HTTP SERVICE – FINAL (v5)
/// Centralized network layer for Raonson
/// =====================================================

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpService {
  HttpService._();

  // =====================================================
  // CONFIG
  // =====================================================

  static const Duration _timeout = Duration(seconds: 20);

  // =====================================================
  // HEADERS
  // =====================================================

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

  // =====================================================
  // TOKEN STORAGE
  // =====================================================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // =====================================================
  // HTTP METHODS
  // =====================================================

  static Future<dynamic> get(
    String url, {
    bool auth = true,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: await _headers(auth: auth),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    }
  }

  static Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: await _headers(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    }
  }

  static Future<dynamic> put(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: await _headers(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout');
    }
  }

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
    } on TimeoutException {
      throw Exception('Request timeout');
    }
  }

  // =====================================================
  // RESPONSE HANDLER
  // =====================================================

  static dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;

    if (response.body.isEmpty) {
      if (status >= 200 && status < 300) return null;
      throw Exception('Empty response ($status)');
    }

    final data = jsonDecode(response.body);

    if (status >= 200 && status < 300) {
      return data;
    }

    // ================= ERRORS =================

    if (status == 401) {
      throw Exception('Unauthorized');
    }

    if (status == 403) {
      throw Exception('Forbidden');
    }

    if (status == 404) {
      throw Exception('Not found');
    }

    if (status >= 500) {
      throw Exception('Server error');
    }

    if (data is Map && data.containsKey('detail')) {
      throw Exception(data['detail']);
    }

    throw Exception('Request failed ($status)');
  }
}

/// =====================================================
/// HTTP CLIENT – RAONSON CORE
/// Handles all API requests safely
/// =====================================================

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api.dart';
import 'token_storage.dart';
import 'error_handler.dart';

class HttpClient {
  HttpClient._();

  static const Duration _timeout = Duration(seconds: 20);

  // ================= HEADERS =================
  static Future<Map<String, String>> _headers({
    bool auth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ================= GET =================
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
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('Server error');
    }
  }

  // ================= POST =================
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
            body: jsonEncode(body ?? {}),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    }
  }

  // ================= PUT =================
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
            body: jsonEncode(body ?? {}),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
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
      throw NetworkException('No internet connection');
    }
  }

  // ================= RESPONSE HANDLER =================
  static dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;

    dynamic data;
    if (response.body.isNotEmpty) {
      data = jsonDecode(response.body);
    }

    if (status >= 200 && status < 300) {
      return data;
    }

    if (status == 401) {
      throw AuthException('Unauthorized');
    }

    if (status == 403) {
      throw AuthException('Forbidden');
    }

    if (status == 404) {
      throw NotFoundException('Not found');
    }

    if (status >= 500) {
      throw ServerException('Server error');
    }

    throw ApiException(
      data?['message'] ?? 'Unexpected error',
    );
  }
}

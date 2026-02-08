import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api.dart';
import 'session.dart';

class HttpService {
  // ===== HEADERS =====
  static Future<Map<String, String>> _headers() async {
    final token = await Session.getToken();
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  // ===== GET =====
  static Future<dynamic> get(String url) async {
    try {
      final res = await http
          .get(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: 15));

      return _handleResponse(res);
    } catch (e) {
      _handleError(e);
    }
  }

  // ===== POST =====
  static Future<dynamic> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(res);
    } catch (e) {
      _handleError(e);
    }
  }

  // ===== PUT =====
  static Future<dynamic> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await http
          .put(
            Uri.parse(url),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(res);
    } catch (e) {
      _handleError(e);
    }
  }

  // ===== DELETE =====
  static Future<dynamic> delete(String url) async {
    try {
      final res = await http
          .delete(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: 15));

      return _handleResponse(res);
    } catch (e) {
      _handleError(e);
    }
  }

  // ===== RESPONSE =====
  static dynamic _handleResponse(http.Response res) {
    final status = res.statusCode;
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;

    if (status >= 200 && status < 300) {
      return body;
    }

    if (status == 401) {
      throw Exception('Unauthorized');
    }

    if (status == 403) {
      throw Exception('Forbidden');
    }

    if (status == 404) {
      throw Exception('Not found');
    }

    throw Exception(body?['detail'] ?? 'Server error');
  }

  // ===== ERROR =====
  static Never _handleError(dynamic e) {
    if (e is SocketException) {
      throw Exception('No internet connection');
    }

    if (e is HttpException) {
      throw Exception('HTTP error');
    }

    if (e.toString().contains('Timeout')) {
      throw Exception('Request timeout');
    }

    throw Exception(e.toString());
  }
}

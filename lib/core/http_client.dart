import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api.dart';
import 'token_storage.dart';
import 'error_handler.dart';
import 'network_checker.dart';

/// =====================================================
/// HTTP CLIENT (FINAL, SAFE, PRODUCTION-READY)
/// -----------------------------------------------------
/// - Base URL from Api
/// - Auth header (Bearer token)
/// - Timeouts
/// - Retry (basic)
/// - JSON encode/decode
/// - Multipart upload support
/// - Unified error handling
/// =====================================================
class HttpClient {
  HttpClient._();

  static const Duration _timeout = Duration(seconds: 20);
  static const int _maxRetries = 2;

  // =========================
  // PUBLIC METHODS
  // =========================

  static Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
    Map<String, String>? headers,
  }) {
    return _request(
      method: 'GET',
      path: path,
      query: query,
      auth: auth,
      headers: headers,
    );
  }

  static Future<dynamic> post(
    String path, {
    dynamic body,
    bool auth = true,
    Map<String, String>? headers,
  }) {
    return _request(
      method: 'POST',
      path: path,
      body: body,
      auth: auth,
      headers: headers,
    );
  }

  static Future<dynamic> put(
    String path, {
    dynamic body,
    bool auth = true,
    Map<String, String>? headers,
  }) {
    return _request(
      method: 'PUT',
      path: path,
      body: body,
      auth: auth,
      headers: headers,
    );
  }

  static Future<dynamic> delete(
    String path, {
    dynamic body,
    bool auth = true,
    Map<String, String>? headers,
  }) {
    return _request(
      method: 'DELETE',
      path: path,
      body: body,
      auth: auth,
      headers: headers,
    );
  }

  // =========================
  // MULTIPART UPLOAD
  // =========================
  static Future<dynamic> uploadFile(
    String path, {
    required File file,
    String field = 'file',
    Map<String, String>? fields,
    bool auth = true,
    Map<String, String>? headers,
  }) async {
    await NetworkChecker.ensureOnline();

    final uri = Uri.parse(Api.baseUrl + path);

    final request = http.MultipartRequest('POST', uri);

    if (auth) {
      final token = await TokenStorage.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    request.headers.addAll({
      'Accept': 'application/json',
      if (headers != null) ...headers,
    });

    if (fields != null) {
      request.fields.addAll(fields);
    }

    request.files.add(
      await http.MultipartFile.fromPath(field, file.path),
    );

    try {
      final streamed =
          await request.send().timeout(_timeout);
      final response =
          await http.Response.fromStream(streamed);

      return _handleResponse(response);
    } on TimeoutException {
      throw AppError.timeout();
    } on SocketException {
      throw AppError.network();
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  // =========================
  // CORE REQUEST
  // =========================
  static Future<dynamic> _request({
    required String method,
    required String path,
    Map<String, String>? query,
    dynamic body,
    required bool auth,
    Map<String, String>? headers,
  }) async {
    await NetworkChecker.ensureOnline();

    final uri = Uri.parse(Api.baseUrl + path)
        .replace(queryParameters: query);

    int attempt = 0;

    while (true) {
      try {
        final requestHeaders = <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        };

        if (auth) {
          final token = await TokenStorage.getToken();
          if (token != null) {
            requestHeaders['Authorization'] = 'Bearer $token';
          }
        }

        http.Response response;

        switch (method) {
          case 'GET':
            response = await http
                .get(uri, headers: requestHeaders)
                .timeout(_timeout);
            break;
          case 'POST':
            response = await http
                .post(
                  uri,
                  headers: requestHeaders,
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(_timeout);
            break;
          case 'PUT':
            response = await http
                .put(
                  uri,
                  headers: requestHeaders,
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(_timeout);
            break;
          case 'DELETE':
            response = await http
                .delete(
                  uri,
                  headers: requestHeaders,
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(_timeout);
            break;
          default:
            throw AppError.unknown('Unsupported HTTP method');
        }

        return _handleResponse(response);
      } on TimeoutException {
        if (attempt++ < _maxRetries) continue;
        throw AppError.timeout();
      } on SocketException {
        if (attempt++ < _maxRetries) continue;
        throw AppError.network();
      }
    }
  }

  // =========================
  // RESPONSE HANDLER
  // =========================
  static dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;

    if (kDebugMode) {
      debugPrint(
        '[HTTP] ${response.request?.method} '
        '${response.request?.url} -> $status',
      );
    }

    if (response.body.isEmpty) {
      if (status >= 200 && status < 300) return null;
      throw ErrorHandler.fromStatus(status, null);
    }

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = response.body;
    }

    if (status >= 200 && status < 300) {
      return data;
    }

    throw ErrorHandler.fromStatus(status, data);
  }
}

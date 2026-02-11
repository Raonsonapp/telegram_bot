import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'app_config.dart'; // Боварӣ ҳосил кун, ки адрес дуруст аст
import 'token_storage.dart';

class HttpClient {
  HttpClient._();

  static const Duration _timeout = Duration(seconds: 20);

  static Future<dynamic> post(String path, {dynamic body, bool auth = true}) {
    return _request(method: 'POST', path: path, body: body, auth: auth);
  }

  static Future<dynamic> get(String path, {bool auth = true}) {
    return _request(method: 'GET', path: path, auth: auth);
  }

  static Future<dynamic> _request({
    required String method,
    required String path,
    dynamic body,
    required bool auth,
  }) async {
    // Истифодаи AppConfig.apiBase, ки худат сохтаӣ
    final uri = Uri.parse('${AppConfig.apiBase}$path');
    
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    try {
      http.Response response;
      if (method == 'POST') {
        response = await http.post(uri, headers: headers, body: jsonEncode(body)).timeout(_timeout);
      } else {
        response = await http.get(uri, headers: headers).timeout(_timeout);
      }
      return _handleResponse(response);
    } catch (e) {
      rethrow; 
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }
}

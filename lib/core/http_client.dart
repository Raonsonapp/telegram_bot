import 'package:dio/dio.dart';

import 'api.dart';

class HttpClient {
  HttpClient({String? token}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: token == null ? {} : {'Authorization': 'Bearer $token'},
      ),
    );
  }

  late final Dio _dio;

  Future<Response<dynamic>> get(String path) => _dio.get(path);

  Future<Response<dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) {
    return _dio.post(path, data: data);
  }
}

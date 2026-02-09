import 'package:dio/dio.dart';

class ErrorHandler {
  static String message(Object error) {
    if (error is DioException) {
      return error.response?.data?['message']?.toString() ??
          error.message ??
          'Network error';
    }
    return 'Something went wrong';
  }
}

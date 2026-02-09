/// =====================================================
/// ERROR HANDLER – RAONSON CORE
/// Centralized error parsing & mapping
/// =====================================================

import 'dart:io';

class AppError {
  final String message;
  final int? code;
  final bool isNetwork;
  final bool isAuth;
  final bool isServer;

  const AppError({
    required this.message,
    this.code,
    this.isNetwork = false,
    this.isAuth = false,
    this.isServer = false,
  });

  @override
  String toString() =>
      'AppError(code: $code, message: $message)';
}

class ErrorHandler {
  ErrorHandler._();

  // =====================================================
  // PARSE ANY ERROR
  // =====================================================
  static AppError parse(dynamic error) {
    // -------- Network --------
    if (error is SocketException) {
      return const AppError(
        message: 'No internet connection',
        isNetwork: true,
      );
    }

    // -------- Timeout --------
    if (error is TimeoutException) {
      return const AppError(
        message: 'Connection timeout',
        isNetwork: true,
      );
    }

    // -------- HTTP MAP --------
    if (error is HttpError) {
      return _fromHttp(error);
    }

    // -------- String --------
    if (error is String) {
      return AppError(message: error);
    }

    // -------- Unknown --------
    return const AppError(
      message: 'Something went wrong',
      isServer: true,
    );
  }

  // =====================================================
  // HTTP ERROR
  // =====================================================
  static AppError _fromHttp(HttpError e) {
    switch (e.statusCode) {
      case 400:
        return AppError(
          message: e.message ?? 'Invalid request',
          code: 400,
        );

      case 401:
        return const AppError(
          message: 'Session expired. Please login again.',
          code: 401,
          isAuth: true,
        );

      case 403:
        return const AppError(
          message: 'Access denied',
          code: 403,
          isAuth: true,
        );

      case 404:
        return const AppError(
          message: 'Not found',
          code: 404,
        );

      case 500:
      case 502:
      case 503:
        return const AppError(
          message: 'Server error. Try again later.',
          code: 500,
          isServer: true,
        );

      default:
        return AppError(
          message: e.message ?? 'Unexpected error',
          code: e.statusCode,
        );
    }
  }
}

/// =====================================================
/// HTTP ERROR WRAPPER
/// Used by http_client
/// =====================================================
class HttpError {
  final int statusCode;
  final String? message;

  HttpError(this.statusCode, {this.message});
}

// lib/core/error_handler.dart
// =====================================================
// ERROR HANDLER – Raonson Social App
// Centralized error parsing, mapping, logging & UI-safe messages
// Compatible with FastAPI backend (raonson-me.onrender.com)
// =====================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Error types used across the app
enum AppErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  cancelled,
  unknown,
}

/// Unified application error
class AppError implements Exception {
  final AppErrorType type;
  final String message;
  final int? statusCode;
  final dynamic details;

  AppError({
    required this.type,
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'AppError(type: $type, status: $statusCode, message: $message)';
  }
}

/// Central error handler
class ErrorHandler {
  ErrorHandler._();

  // =====================================================
  // PUBLIC API
  // =====================================================

  /// Parse any error thrown by HTTP / Socket / IO / Dart
  static AppError handle(dynamic error, {StackTrace? stackTrace}) {
    // Timeout
    if (error is TimeoutException) {
      return _timeout(error);
    }

    // Socket / Network
    if (error is SocketException) {
      return _network(error);
    }

    // HTTP errors wrapped as HttpException
    if (error is HttpException) {
      return _http(error);
    }

    // Custom backend error map
    if (error is Map<String, dynamic>) {
      return _fromBackendMap(error);
    }

    // JSON string error
    if (error is String) {
      return _fromString(error);
    }

    // Unknown
    return _unknown(error, stackTrace);
  }

  /// Convert AppError to user-friendly message (UI safe)
  static String uiMessage(AppError error) {
    switch (error.type) {
      case AppErrorType.network:
        return 'No internet connection. Please check your network.';
      case AppErrorType.timeout:
        return 'Connection timed out. Please try again.';
      case AppErrorType.unauthorized:
        return 'Session expired. Please log in again.';
      case AppErrorType.forbidden:
        return 'You do not have permission to perform this action.';
      case AppErrorType.notFound:
        return 'Requested resource was not found.';
      case AppErrorType.validation:
        return error.message.isNotEmpty
            ? error.message
            : 'Invalid input. Please check your data.';
      case AppErrorType.server:
        return 'Server error. Please try again later.';
      case AppErrorType.cancelled:
        return 'Request was cancelled.';
      case AppErrorType.unknown:
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Whether error should force logout
  static bool shouldLogout(AppError error) {
    return error.type == AppErrorType.unauthorized;
  }

  // =====================================================
  // INTERNAL PARSERS
  // =====================================================

  static AppError _timeout(TimeoutException e) {
    return AppError(
      type: AppErrorType.timeout,
      message: e.message ?? 'Request timeout',
    );
  }

  static AppError _network(SocketException e) {
    return AppError(
      type: AppErrorType.network,
      message: e.message,
    );
  }

  static AppError _http(HttpException e) {
    final code = e.message.contains('401')
        ? 401
        : e.message.contains('403')
            ? 403
            : e.message.contains('404')
                ? 404
                : 500;

    return _fromStatusCode(
      code,
      message: e.message,
    );
  }

  static AppError _fromBackendMap(Map<String, dynamic> map) {
    final status = map['status'] ?? map['status_code'];
    final detail = map['detail'] ?? map['message'] ?? '';

    if (status is int) {
      return _fromStatusCode(status, message: detail, details: map);
    }

    return AppError(
      type: AppErrorType.unknown,
      message: detail.toString(),
      details: map,
    );
  }

  static AppError _fromString(String value) {
    // Try JSON decode
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return _fromBackendMap(decoded);
      }
    } catch (_) {}

    return AppError(
      type: AppErrorType.unknown,
      message: value,
    );
  }

  static AppError _fromStatusCode(
    int statusCode, {
    String? message,
    dynamic details,
  }) {
    switch (statusCode) {
      case 400:
      case 422:
        return AppError(
          type: AppErrorType.validation,
          statusCode: statusCode,
          message: message ?? 'Validation error',
          details: details,
        );
      case 401:
        return AppError(
          type: AppErrorType.unauthorized,
          statusCode: statusCode,
          message: message ?? 'Unauthorized',
        );
      case 403:
        return AppError(
          type: AppErrorType.forbidden,
          statusCode: statusCode,
          message: message ?? 'Forbidden',
        );
      case 404:
        return AppError(
          type: AppErrorType.notFound,
          statusCode: statusCode,
          message: message ?? 'Not found',
        );
      case 408:
        return AppError(
          type: AppErrorType.timeout,
          statusCode: statusCode,
          message: message ?? 'Request timeout',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return AppError(
          type: AppErrorType.server,
          statusCode: statusCode,
          message: message ?? 'Server error',
        );
      default:
        return AppError(
          type: AppErrorType.unknown,
          statusCode: statusCode,
          message: message ?? 'Unknown error',
        );
    }
  }

  static AppError _unknown(dynamic error, StackTrace? stackTrace) {
    return AppError(
      type: AppErrorType.unknown,
      message: error.toString(),
      details: stackTrace?.toString(),
    );
  }
}

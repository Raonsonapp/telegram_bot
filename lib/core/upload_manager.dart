import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import 'api.dart';
import 'http_client.dart';
import 'session_manager.dart';
import 'error_handler.dart';

/// =====================================================
/// UPLOAD MANAGER – FINAL v5
/// Handles:
/// - Image / video upload (posts, reels, stories, avatar)
/// - Multipart, progress, cancel
/// - Auth headers, retries
/// =====================================================
class UploadManager {
  UploadManager._();

  static const int _defaultTimeoutSec = 120;

  // =========================
  // PUBLIC API
  // =========================

  /// Upload a file with progress callback
  static Future<UploadResult> uploadFile({
    required File file,
    required UploadType type,
    String? fieldName,
    String? filename,
    Map<String, String>? extraFields,
    void Function(double progress)? onProgress,
    Duration timeout = const Duration(seconds: _defaultTimeoutSec),
    CancelToken? cancelToken,
  }) async {
    final uri = Uri.parse(_endpointFor(type));
    final token = await SessionManager.getAccessToken();

    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll({
      'Authorization': token != null ? 'Bearer $token' : '',
      ...HttpClient.defaultHeaders,
    });

    if (extraFields != null) {
      req.fields.addAll(extraFields);
    }

    final fileField = fieldName ?? 'file';
    final fname = filename ?? p.basename(file.path);

    final length = await file.length();
    final stream = http.ByteStream(_progressStream(
      file.openRead(),
      length,
      onProgress,
      cancelToken,
    ));

    req.files.add(
      http.MultipartFile(
        fileField,
        stream,
        length,
        filename: fname,
      ),
    );

    final res = await _sendWithTimeout(req, timeout, cancelToken);
    return _parseUploadResponse(res);
  }

  /// Upload raw bytes (camera / memory)
  static Future<UploadResult> uploadBytes({
    required Uint8List bytes,
    required UploadType type,
    String fieldName = 'file',
    String filename = 'upload.bin',
    Map<String, String>? extraFields,
    void Function(double progress)? onProgress,
    Duration timeout = const Duration(seconds: _defaultTimeoutSec),
    CancelToken? cancelToken,
  }) async {
    final uri = Uri.parse(_endpointFor(type));
    final token = await SessionManager.getAccessToken();

    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll({
      'Authorization': token != null ? 'Bearer $token' : '',
      ...HttpClient.defaultHeaders,
    });

    if (extraFields != null) {
      req.fields.addAll(extraFields);
    }

    final total = bytes.length;
    final controller = StreamController<List<int>>();

    int sent = 0;
    controller.addStream(Stream<List<int>>.fromIterable(
      bytes.map((b) {
        sent++;
        if (onProgress != null && total > 0) {
          onProgress(sent / total);
        }
        if (cancelToken?.isCancelled == true) {
          controller.close();
        }
        return [b];
      }),
    ));

    req.files.add(
      http.MultipartFile(
        fieldName,
        controller.stream,
        total,
        filename: filename,
      ),
    );

    final res = await _sendWithTimeout(req, timeout, cancelToken);
    return _parseUploadResponse(res);
  }

  // =========================
  // INTERNALS
  // =========================

  static String _endpointFor(UploadType type) {
    switch (type) {
      case UploadType.avatar:
        return Api.uploadAvatar;
      case UploadType.post:
        return Api.uploadPostMedia;
      case UploadType.reel:
        return Api.uploadReelVideo;
      case UploadType.story:
        return Api.uploadStoryMedia;
      case UploadType.message:
        return Api.uploadMessageMedia;
    }
  }

  static Future<http.StreamedResponse> _sendWithTimeout(
    http.MultipartRequest req,
    Duration timeout,
    CancelToken? cancelToken,
  ) async {
    try {
      final sendFuture = req.send();
      final res = await sendFuture.timeout(timeout);
      if (cancelToken?.isCancelled == true) {
        throw UploadCancelled();
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        final body = await res.stream.bytesToString();
        throw ErrorHandler.fromHttp(res.statusCode, body);
      }
      return res;
    } on TimeoutException {
      throw UploadTimeout();
    }
  }

  static UploadResult _parseUploadResponse(http.StreamedResponse res) async {
    final body = await res.stream.bytesToString();
    final data = HttpClient.parseJson(body);

    return UploadResult(
      ok: data['ok'] == true,
      url: data['url'] as String?,
      id: data['id'],
      raw: data,
    );
  }

  static Stream<List<int>> _progressStream(
    Stream<List<int>> source,
    int total,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  ) async* {
    int sent = 0;
    await for (final chunk in source) {
      if (cancelToken?.isCancelled == true) {
        throw UploadCancelled();
      }
      sent += chunk.length;
      if (onProgress != null && total > 0) {
        onProgress(sent / total);
      }
      yield chunk;
    }
  }
}

// =========================
// MODELS / HELPERS
// =========================

enum UploadType { avatar, post, reel, story, message }

class UploadResult {
  final bool ok;
  final String? url;
  final dynamic id;
  final Map<String, dynamic> raw;

  UploadResult({
    required this.ok,
    required this.url,
    required this.id,
    required this.raw,
  });
}

class CancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class UploadTimeout implements Exception {}

class UploadCancelled implements Exception {}

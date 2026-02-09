/// =====================================================
/// UPLOAD MANAGER – RAONSON CORE
/// Handles media uploads with progress & auth
/// =====================================================

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api.dart';
import 'token_storage.dart';

typedef UploadProgress = void Function(int sent, int total);

class UploadManager {
  UploadManager._();

  // =====================================================
  // UPLOAD FILE
  // =====================================================
  static Future<String?> uploadFile({
    required File file,
    required String endpoint,
    String fieldName = 'file',
    Map<String, String>? fields,
    UploadProgress? onProgress,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return null;

    final uri = Uri.parse(endpoint);

    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    if (fields != null) {
      request.fields.addAll(fields);
    }

    final length = await file.length();

    final stream = http.ByteStream(
      file.openRead().transform(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            sink.add(data);
            if (onProgress != null) {
              _sentBytes += data.length;
              onProgress(_sentBytes, length);
            }
          },
        ),
      ),
    );

    final multipart = http.MultipartFile(
      fieldName,
      stream,
      length,
      filename: file.path.split('/').last,
    );

    request.files.add(multipart);

    _sentBytes = 0;

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return resBody; // backend returns uploaded url
    }

    return null;
  }

  // =====================================================
  // INTERNAL
  // =====================================================
  static int _sentBytes = 0;
}

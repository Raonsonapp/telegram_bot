/// lib/core/upload_service.dart
/// =====================================================
/// UPLOAD SERVICE – FINAL v5
/// Handles media upload (image / video)
/// Used by: Post, Story, Reel
/// =====================================================

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'api.dart';
import 'session.dart';

class UploadService {
  UploadService._();

  // =====================================================
  // IMAGE UPLOAD
  // =====================================================

  static Future<String> uploadImage({
    required File file,
    required String type, // post | story | reel
  }) async {
    final token = Session.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('${Api.baseUrl}/upload/image');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
      })
      ..fields['type'] = type
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: basename(file.path),
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Image upload failed: $body');
    }

    return body; // backend → returns mediaUrl (string)
  }

  // =====================================================
  // VIDEO UPLOAD
  // =====================================================

  static Future<String> uploadVideo({
    required File file,
    required String type, // post | story | reel
  }) async {
    final token = Session.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('${Api.baseUrl}/upload/video');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
      })
      ..fields['type'] = type
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: basename(file.path),
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Video upload failed: $body');
    }

    return body; // backend → returns mediaUrl (string)
  }
}

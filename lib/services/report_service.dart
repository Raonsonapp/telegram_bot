// lib/services/report_service.dart

import '../core/api.dart';
import '../core/http_service.dart';

class ReportService {
  // =========================
  // REPORT POST
  // =========================
  static Future<bool> reportPost({
    required int postId,
    required String reason,
    String? description,
  }) async {
    final res = await HttpService.post(
      '${Api.baseUrl}/reports/post',
      body: {
        'post_id': postId,
        'reason': reason,
        'description': description ?? '',
      },
      auth: true,
    );

    return res != null;
  }

  // =========================
  // REPORT REEL
  // =========================
  static Future<bool> reportReel({
    required int reelId,
    required String reason,
    String? description,
  }) async {
    final res = await HttpService.post(
      '${Api.baseUrl}/reports/reel',
      body: {
        'reel_id': reelId,
        'reason': reason,
        'description': description ?? '',
      },
      auth: true,
    );

    return res != null;
  }

  // =========================
  // REPORT USER
  // =========================
  static Future<bool> reportUser({
    required int userId,
    required String reason,
    String? description,
  }) async {
    final res = await HttpService.post(
      '${Api.baseUrl}/reports/user',
      body: {
        'user_id': userId,
        'reason': reason,
        'description': description ?? '',
      },
      auth: true,
    );

    return res != null;
  }

  // =========================
  // REPORT COMMENT
  // =========================
  static Future<bool> reportComment({
    required int commentId,
    required String reason,
    String? description,
  }) async {
    final res = await HttpService.post(
      '${Api.baseUrl}/reports/comment',
      body: {
        'comment_id': commentId,
        'reason': reason,
        'description': description ?? '',
      },
      auth: true,
    );

    return res != null;
  }

  // =========================
  // REPORT REASONS (STATIC)
  // =========================
  static List<String> reportReasons = const [
    'Spam',
    'Harassment or hate speech',
    'Violence',
    'Nudity or sexual content',
    'False information',
    'Scam or fraud',
    'Intellectual property violation',
    'Other',
  ];
}

// lib/services/report_service.dart
// =====================================================
// REPORT SERVICE – FINAL v5 (BUILD SAFE)
// Handles reporting:
// - Post
// - Reel
// - Comment
// - User
// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';

class ReportService {
  // =====================================================
  // INTERNAL HELPER
  // =====================================================

  static Future<bool> _sendReport({
    required String targetType, // post | reel | comment | user
    required int targetId,
    required String reason,
    String? description,
  }) async {
    final res = await HttpService.post(
      '${Api.api}/reports',
      body: {
        'target_type': targetType,
        'target_id': targetId,
        'reason': reason,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
      auth: true,
    );

    return res != null;
  }

  // =====================================================
  // REPORT POST
  // =====================================================

  static Future<bool> reportPost({
    required int postId,
    required String reason,
    String? description,
  }) {
    return _sendReport(
      targetType: 'post',
      targetId: postId,
      reason: reason,
      description: description,
    );
  }

  // =====================================================
  // REPORT REEL
  // =====================================================

  static Future<bool> reportReel({
    required int reelId,
    required String reason,
    String? description,
  }) {
    return _sendReport(
      targetType: 'reel',
      targetId: reelId,
      reason: reason,
      description: description,
    );
  }

  // =====================================================
  // REPORT COMMENT
  // =====================================================

  static Future<bool> reportComment({
    required int commentId,
    required String reason,
    String? description,
  }) {
    return _sendReport(
      targetType: 'comment',
      targetId: commentId,
      reason: reason,
      description: description,
    );
  }

  // =====================================================
  // REPORT USER
  // =====================================================

  static Future<bool> reportUser({
    required int userId,
    required String reason,
    String? description,
  }) {
    return _sendReport(
      targetType: 'user',
      targetId: userId,
      reason: reason,
      description: description,
    );
  }

  // =====================================================
  // STATIC REPORT REASONS (UI USE)
  // =====================================================

  static const List<String> reportReasons = [
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

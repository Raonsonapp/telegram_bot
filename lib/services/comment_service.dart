/// lib/services/comment_service.dart
/// =====================================================
/// COMMENT SERVICE – FINAL v5 (FIXED)
/// Compatible with:
/// - Api v5 FINAL
/// - HttpService
/// - CI / Analyzer
/// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';

class CommentService {
  // =====================================================
  // GET COMMENTS BY POST
  // =====================================================
  /// GET /comments/{postId}
  static Future<List<Map<String, dynamic>>> getComments(
    int postId,
  ) async {
    final res = await HttpService.get(
      Api.getComments(postId),
      auth: true,
    );

    if (res is! List) {
      return [];
    }

    return res
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  // =====================================================
  // ADD COMMENT
  // =====================================================
  /// POST /comments/{postId}
  static Future<Map<String, dynamic>> addComment({
    required int postId,
    required String text,
  }) async {
    final res = await HttpService.post(
      Api.addComment(postId),
      body: {
        'text': text,
      },
      auth: true,
    );

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid add comment response');
    }

    return res;
  }

  // =====================================================
  // DELETE COMMENT
  // =====================================================
  /// DELETE /comments/{commentId}
  static Future<void> deleteComment(int commentId) async {
    await HttpService.delete(
      '${Api.comments}/$commentId',
      auth: true,
    );
  }

  // =====================================================
  // LIKE COMMENT
  // =====================================================
  /// POST /comments/{commentId}/like
  static Future<void> likeComment(int commentId) async {
    await HttpService.post(
      '${Api.comments}/$commentId/like',
      body: const {},
      auth: true,
    );
  }

  // =====================================================
  // UNLIKE COMMENT
  // =====================================================
  /// POST /comments/{commentId}/unlike
  static Future<void> unlikeComment(int commentId) async {
    await HttpService.post(
      '${Api.comments}/$commentId/unlike',
      body: const {},
      auth: true,
    );
  }
}

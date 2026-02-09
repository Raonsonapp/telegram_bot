/// lib/services/comment_service.dart
/// Comment Service – Raonson v5
/// Full production-ready implementation

import '../core/api.dart';
import '../core/http_service.dart';
import '../core/session.dart';

class CommentService {
  /// ================================
  /// GET COMMENTS BY POST
  /// ================================
  /// GET /comments/{postId}
  static Future<List<Map<String, dynamic>>> getComments(
    int postId,
  ) async {
    final token = await Session.getToken();

    final res = await HttpService.get(
      '${Api.comments}/$postId',
      auth: token != null,
    );

    if (res is List) {
      return List<Map<String, dynamic>>.from(res);
    }

    return [];
  }

  /// ================================
  /// ADD COMMENT
  /// ================================
  /// POST /comments/add/{postId}
  static Future<Map<String, dynamic>> addComment({
    required int postId,
    required String text,
  }) async {
    final token = await Session.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final res = await HttpService.post(
      '${Api.addComment}/$postId',
      {
        'text': text,
      },
      auth: true,
    );

    return Map<String, dynamic>.from(res);
  }

  /// ================================
  /// DELETE COMMENT
  /// ================================
  /// DELETE /comments/{commentId}
  static Future<void> deleteComment(int commentId) async {
    final token = await Session.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    await HttpService.delete(
      '${Api.comments}/$commentId',
      auth: true,
    );
  }

  /// ================================
  /// LIKE COMMENT
  /// ================================
  /// POST /comments/{commentId}/like
  static Future<void> likeComment(int commentId) async {
    final token = await Session.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    await HttpService.post(
      '${Api.comments}/$commentId/like',
      {},
      auth: true,
    );
  }

  /// ================================
  /// UNLIKE COMMENT
  /// ================================
  /// POST /comments/{commentId}/unlike
  static Future<void> unlikeComment(int commentId) async {
    final token = await Session.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    await HttpService.post(
      '${Api.comments}/$commentId/unlike',
      {},
      auth: true,
    );
  }
}

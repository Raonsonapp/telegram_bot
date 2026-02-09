// lib/services/post_actions_service.dart
// =====================================================
// POST ACTIONS SERVICE – FINAL v5
// Handles:
// - Like post
// - Unlike post
// - Check liked state
// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';
import '../core/session.dart';

class PostActionsService {
  // =====================================================
  // CHECK IF POST IS LIKED
  // =====================================================
  /// GET /posts/{id}/is-liked
  static Future<bool> isLiked(int postId) async {
    final token = await Session.getToken();

    final res = await HttpService.get(
      '${Api.posts}/$postId/is-liked',
      auth: token != null,
    );

    if (res is Map && res['liked'] == true) {
      return true;
    }
    return false;
  }

  // =====================================================
  // LIKE POST
  // =====================================================
  /// POST /posts/{id}/like
  static Future<int> like({
    required int postId,
    required int currentLikes,
  }) async {
    final token = await Session.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    await HttpService.post(
      Api.likePost(postId),
      body: {},
      auth: true,
    );

    return currentLikes + 1;
  }

  // =====================================================
  // UNLIKE POST
  // =====================================================
  /// POST /posts/{id}/unlike
  static Future<int> unlike({
    required int postId,
    required int currentLikes,
  }) async {
    final token = await Session.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    await HttpService.post(
      Api.unlikePost(postId),
      body: {},
      auth: true,
    );

    return currentLikes > 0 ? currentLikes - 1 : 0;
  }
}

/// lib/services/like_service.dart
/// Like Service – Raonson v5
/// Handles likes for posts, reels, comments
/// 100% backend-connected & build-safe

import '../core/api.dart';
import '../core/http_service.dart';
import '../core/session.dart';

class LikeService {
  // ================================
  // POST LIKE (POST / REEL / COMMENT)
  // ================================
  /// type: post | reel | comment
  /// POST /{type}s/{id}/like
  static Future<void> like({
    required String type,
    required int id,
  }) async {
    final token = await Session.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final endpoint = _endpoint(type, id, action: 'like');

    await HttpService.post(
      endpoint,
      {},
      auth: true,
    );
  }

  // ================================
  // POST UNLIKE
  // ================================
  /// POST /{type}s/{id}/unlike
  static Future<void> unlike({
    required String type,
    required int id,
  }) async {
    final token = await Session.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final endpoint = _endpoint(type, id, action: 'unlike');

    await HttpService.post(
      endpoint,
      {},
      auth: true,
    );
  }

  // ================================
  // CHECK IF LIKED
  // ================================
  /// GET /{type}s/{id}/is-liked
  static Future<bool> isLiked({
    required String type,
    required int id,
  }) async {
    final token = await Session.getToken();

    final endpoint = _endpoint(type, id, action: 'is-liked');

    final res = await HttpService.get(
      endpoint,
      auth: token != null,
    );

    if (res is Map && res['liked'] == true) {
      return true;
    }

    return false;
  }

  // ================================
  // INTERNAL ENDPOINT BUILDER
  // ================================
  static String _endpoint(
    String type,
    int id, {
    required String action,
  }) {
    switch (type) {
      case 'post':
        return '${Api.baseUrl}/posts/$id/$action';
      case 'reel':
        return '${Api.baseUrl}/reels/$id/$action';
      case 'comment':
        return '${Api.baseUrl}/comments/$id/$action';
      default:
        throw Exception('Invalid like type: $type');
    }
  }
}

/// lib/services/like_service.dart
/// =====================================================
/// LIKE SERVICE – FINAL v5 (FIXED)
/// Handles likes for:
/// - Posts
/// - Reels
/// - Comments
/// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';

class LikeService {
  // =====================================================
  // LIKE
  // =====================================================
  /// type: post | reel | comment
  static Future<void> like({
    required String type,
    required int id,
  }) async {
    final endpoint = _likeEndpoint(type, id);

    await HttpService.post(
      endpoint,
      body: const {},
      auth: true,
    );
  }

  // =====================================================
  // UNLIKE
  // =====================================================
  static Future<void> unlike({
    required String type,
    required int id,
  }) async {
    final endpoint = _unlikeEndpoint(type, id);

    await HttpService.post(
      endpoint,
      body: const {},
      auth: true,
    );
  }

  // =====================================================
  // INTERNAL HELPERS (API v5 SAFE)
  // =====================================================

  static String _likeEndpoint(String type, int id) {
    switch (type) {
      case 'post':
        return Api.likePost(id);
      case 'reel':
        return Api.likeReel(id);
      case 'comment':
        return '${Api.comments}/$id/like';
      default:
        throw Exception('Invalid like type: $type');
    }
  }

  static String _unlikeEndpoint(String type, int id) {
    switch (type) {
      case 'post':
        return Api.unlikePost(id);
      case 'reel':
        return Api.unlikeReel(id);
      case 'comment':
        return '${Api.comments}/$id/unlike';
      default:
        throw Exception('Invalid like type: $type');
    }
  }
}

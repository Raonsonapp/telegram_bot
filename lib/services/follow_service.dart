/// lib/services/follow_service.dart
/// Raonson v5 – Follow System
/// FULL backend-connected service
/// Build-safe, no missing methods

import '../core/api.dart';
import '../core/http_service.dart';
import '../core/session.dart';

class FollowService {
  // ==============================
  // FOLLOW USER
  // ==============================
  /// POST /follow/{username}
  static Future<void> followUser(String username) async {
    final token = await Session.getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    await HttpService.post(
      '${Api.follow}/$username',
      {},
      auth: true,
    );
  }

  // ==============================
  // UNFOLLOW USER
  // ==============================
  /// POST /unfollow/{username}
  static Future<void> unfollowUser(String username) async {
    final token = await Session.getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    await HttpService.post(
      '${Api.unfollow}/$username',
      {},
      auth: true,
    );
  }

  // ==============================
  // GET FOLLOWERS
  // ==============================
  /// GET /followers/{username}
  static Future<List<dynamic>> getFollowers(String username) async {
    final res = await HttpService.get(
      '${Api.followers}/$username',
      auth: true,
    );

    if (res is List) {
      return res;
    }
    return [];
  }

  // ==============================
  // GET FOLLOWING
  // ==============================
  /// GET /following/{username}
  static Future<List<dynamic>> getFollowing(String username) async {
    final res = await HttpService.get(
      '${Api.following}/$username',
      auth: true,
    );

    if (res is List) {
      return res;
    }
    return [];
  }

  // ==============================
  // CHECK IS FOLLOWING
  // ==============================
  /// GET /follow/is-following/{username}
  static Future<bool> isFollowing(String username) async {
    final res = await HttpService.get(
      '${Api.follow}/is-following/$username',
      auth: true,
    );

    if (res is Map && res['following'] == true) {
      return true;
    }
    return false;
  }

  // ==============================
  // GET FOLLOW COUNTS
  // ==============================
  /// GET /follow/counts/{username}
  static Future<Map<String, int>> getFollowCounts(String username) async {
    final res = await HttpService.get(
      '${Api.follow}/counts/$username',
      auth: true,
    );

    if (res is Map) {
      return {
        'followers': res['followers'] ?? 0,
        'following': res['following'] ?? 0,
      };
    }

    return {'followers': 0, 'following': 0};
  }
}

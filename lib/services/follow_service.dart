/// lib/services/follow_service.dart
/// =====================================================
/// FOLLOW SERVICE – FINAL v5 (FIXED)
/// Handles:
/// - Follow / Unfollow
/// - Followers / Following
/// - Is following
/// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/user.dart';

class FollowService {
  // =====================================================
  // FOLLOW USER
  // =====================================================
  /// POST /follow/{username}
  static Future<void> follow(String username) async {
    await HttpService.post(
      Api.followUser(username),
      body: const {},
      auth: true,
    );
  }

  // =====================================================
  // UNFOLLOW USER
  // =====================================================
  /// DELETE /follow/{username}
  static Future<void> unfollow(String username) async {
    await HttpService.delete(
      Api.unfollowUser(username),
      auth: true,
    );
  }

  // =====================================================
  // GET FOLLOWERS
  // =====================================================
  /// GET /follow/{username}/followers
  static Future<List<User>> getFollowers(String username) async {
    final res = await HttpService.get(
      Api.followers(username),
      auth: true,
    );

    return (res as List)
        .map((e) => User.fromJson(e))
        .toList();
  }

  // =====================================================
  // GET FOLLOWING
  // =====================================================
  /// GET /follow/{username}/following
  static Future<List<User>> getFollowing(String username) async {
    final res = await HttpService.get(
      Api.following(username),
      auth: true,
    );

    return (res as List)
        .map((e) => User.fromJson(e))
        .toList();
  }

  // =====================================================
  // CHECK IS FOLLOWING
  // =====================================================
  /// GET /follow/{username}/is-following
  static Future<bool> isFollowing(String username) async {
    final res = await HttpService.get(
      Api.isFollowing(username),
      auth: true,
    );

    if (res is Map && res['is_following'] == true) {
      return true;
    }

    return false;
  }
}

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/user.dart';

class FollowService {
  // ===== FOLLOW =====
  static Future<void> followUser(int userId) async {
    await HttpService.post(
      '${Api.baseUrl}/users/$userId/follow',
      {},
    );
  }

  // ===== UNFOLLOW =====
  static Future<void> unfollowUser(int userId) async {
    await HttpService.post(
      '${Api.baseUrl}/users/$userId/unfollow',
      {},
    );
  }

  // ===== GET FOLLOWERS =====
  static Future<List<User>> getFollowers(int userId) async {
    final res = await HttpService.get(
      '${Api.baseUrl}/users/$userId/followers',
    );

    if (res == null) return [];
    return List<User>.from(
      res.map((e) => User.fromJson(e)),
    );
  }

  // ===== GET FOLLOWING =====
  static Future<List<User>> getFollowing(int userId) async {
    final res = await HttpService.get(
      '${Api.baseUrl}/users/$userId/following',
    );

    if (res == null) return [];
    return List<User>.from(
      res.map((e) => User.fromJson(e)),
    );
  }
}

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/user.dart';

class FollowService {
  // ================= FOLLOW USER =================
  static Future<void> followUser(int userId) async {
    await HttpService.post(
      '${Api.followEndpoint}/$userId/follow',
      {},
    );
  }

  // ================= UNFOLLOW USER =================
  static Future<void> unfollowUser(int userId) async {
    await HttpService.post(
      '${Api.followEndpoint}/$userId/unfollow',
      {},
    );
  }

  // ================= GET FOLLOWERS =================
  static Future<List<User>> getFollowers(int userId) async {
    final res = await HttpService.get(
      '${Api.followEndpoint}/$userId/followers',
    );

    if (res == null || res is! List) {
      return [];
    }

    return res.map<User>((e) => User.fromJson(e)).toList();
  }

  // ================= GET FOLLOWING =================
  static Future<List<User>> getFollowing(int userId) async {
    final res = await HttpService.get(
      '${Api.followEndpoint}/$userId/following',
    );

    if (res == null || res is! List) {
      return [];
    }

    return res.map<User>((e) => User.fromJson(e)).toList();
  }

  // ================= CHECK FOLLOW STATUS =================
  static Future<bool> isFollowing(int userId) async {
    final res = await HttpService.get(
      '${Api.followEndpoint}/$userId/status',
    );

    if (res == null || res is! Map) {
      return false;
    }

    return res['is_following'] == true;
  }
}

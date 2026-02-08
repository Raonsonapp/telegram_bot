import '../core/api.dart';
import '../core/http_service.dart';

class FollowService {
  // ================= FOLLOW USER =================
  static Future<void> followUser(int userId) async {
    await HttpService.post(
      '${Api.followEndpoint}/$userId',
      {},
    );
  }

  // ================= UNFOLLOW USER =================
  static Future<void> unfollowUser(int userId) async {
    await HttpService.delete(
      '${Api.followEndpoint}/$userId',
    );
  }

  // ================= GET FOLLOWERS =================
  static Future<List<dynamic>> getFollowers(int userId) async {
    final res = await HttpService.get(
      '${Api.followEndpoint}/$userId/followers',
    );
    return res is List ? res : [];
  }

  // ================= GET FOLLOWING =================
  static Future<List<dynamic>> getFollowing(int userId) async {
    final res = await HttpService.get(
      '${Api.followEndpoint}/$userId/following',
    );
    return res is List ? res : [];
  }

  // ================= CHECK IS FOLLOWING =================
  static Future<bool> isFollowing(int userId) async {
    final res = await HttpService.get(
      '${Api.followEndpoint}/$userId/is-following',
    );
    return res is Map && res['following'] == true;
  }
}

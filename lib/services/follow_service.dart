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
  static Future<List<UserModel>> getFollowers(int userId) async {
    final response = await HttpService.get(
      '${Api.followEndpoint}/$userId/followers',
    );

    return (response as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  // ================= GET FOLLOWING =================
  static Future<List<UserModel>> getFollowing(int userId) async {
    final response = await HttpService.get(
      '${Api.followEndpoint}/$userId/following',
    );

    return (response as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  // ================= CHECK IS FOLLOWING =================
  static Future<bool> isFollowing(int userId) async {
    final response = await HttpService.get(
      '${Api.followEndpoint}/$userId/is-following',
    );

    return response['following'] == true;
  }
}

import '../core/api.dart';
import '../core/http_service.dart';

class FollowService {
  static Future<void> followUser(int userId) async {
    await HttpService.post(
      '${Api.followEndpoint}/follow',
      {'user_id': userId},
    );
  }

  static Future<void> unfollowUser(int userId) async {
    await HttpService.post(
      '${Api.followEndpoint}/unfollow',
      {'user_id': userId},
    );
  }

  static Future<List<dynamic>> getFollowers(String username) async {
    return await HttpService.get(
      '${Api.followEndpoint}/$username/followers',
    );
  }

  static Future<List<dynamic>> getFollowing(String username) async {
    return await HttpService.get(
      '${Api.followEndpoint}/$username/following',
    );
  }
}

import '../core/api.dart';
import '../core/http_service.dart';

class FollowService {
  static Future<void> follow(String username) async {
    await HttpService.post(
      Api.followEndpoint,
      {'username': username},
    );
  }

  static Future<void> unfollow(String username) async {
    await HttpService.post(
      Api.unfollowEndpoint,
      {'username': username},
    );
  }

  static Future<Map<String, dynamic>> getProfile(String username) async {
    final res = await HttpService.get(
      '${Api.profileEndpoint}/$username',
    );
    return res;
  }
}

import '../core/api.dart';
import '../core/http_service.dart';

class FollowService {
  static Future<void> follow(String username) async {
    await HttpService.post(
      '${Api.baseUrl}/follow',
      {'username': username},
    );
  }

  static Future<void> unfollow(String username) async {
    await HttpService.post(
      '${Api.baseUrl}/unfollow',
      {'username': username},
    );
  }

  static Future<Map<String, dynamic>> getCounts(String username) async {
    final res = await HttpService.get(
      '${Api.baseUrl}/profile/$username/counts',
    );
    return Map<String, dynamic>.from(res);
  }
}

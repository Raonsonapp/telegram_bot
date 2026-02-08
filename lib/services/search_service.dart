import '../core/api.dart';
import '../core/http_service.dart';

class SearchService {
  // search users
  static Future<List<dynamic>> users(String q) async {
    if (q.isEmpty) return [];
    final res = await HttpService.get('${Api.searchUsersEndpoint}?q=$q');
    return List<dynamic>.from(res);
  }

  // search posts
  static Future<List<dynamic>> posts(String q) async {
    if (q.isEmpty) return [];
    final res = await HttpService.get('${Api.searchPostsEndpoint}?q=$q');
    return List<dynamic>.from(res);
  }
}

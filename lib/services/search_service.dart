import '../core/api.dart';
import '../core/http_service.dart';
import '../models/user.dart';
import '../models/post.dart';

class SearchService {
  // ================= SEARCH USERS =================
  static Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final response = await HttpService.get(
      '${Api.searchEndpoint}/users?q=$query',
    );

    return (response as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  // ================= SEARCH POSTS =================
  static Future<List<PostModel>> searchPosts(String query) async {
    if (query.isEmpty) return [];

    final response = await HttpService.get(
      '${Api.searchEndpoint}/posts?q=$query',
    );

    return (response as List)
        .map((json) => PostModel.fromJson(json))
        .toList();
  }

  // ================= TRENDING POSTS =================
  static Future<List<PostModel>> getTrendingPosts() async {
    final response = await HttpService.get(
      '${Api.searchEndpoint}/trending',
    );

    return (response as List)
        .map((json) => PostModel.fromJson(json))
        .toList();
  }

  // ================= SEARCH HASHTAGS =================
  static Future<List<String>> searchHashtags(String query) async {
    if (query.isEmpty) return [];

    final response = await HttpService.get(
      '${Api.searchEndpoint}/hashtags?q=$query',
    );

    return (response as List).map((e) => e.toString()).toList();
  }
}

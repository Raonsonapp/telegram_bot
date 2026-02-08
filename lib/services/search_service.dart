import '../core/api.dart';
import '../core/http_service.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/reel.dart';

class SearchService {
  // ================= SEARCH USERS =================
  static Future<List<User>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final res = await HttpService.get(
      '${Api.searchEndpoint}/users?q=$query',
    );

    if (res == null || res is! List) return [];

    return res.map<User>((e) => User.fromJson(e)).toList();
  }

  // ================= SEARCH POSTS =================
  static Future<List<Post>> searchPosts(String query) async {
    if (query.isEmpty) return [];

    final res = await HttpService.get(
      '${Api.searchEndpoint}/posts?q=$query',
    );

    if (res == null || res is! List) return [];

    return res.map<Post>((e) => Post.fromJson(e)).toList();
  }

  // ================= SEARCH REELS =================
  static Future<List<Reel>> searchReels(String query) async {
    if (query.isEmpty) return [];

    final res = await HttpService.get(
      '${Api.searchEndpoint}/reels?q=$query',
    );

    if (res == null || res is! List) return [];

    return res.map<Reel>((e) => Reel.fromJson(e)).toList();
  }

  // ================= TRENDING POSTS =================
  static Future<List<Post>> getTrendingPosts() async {
    final res = await HttpService.get(
      '${Api.searchEndpoint}/trending/posts',
    );

    if (res == null || res is! List) return [];

    return res.map<Post>((e) => Post.fromJson(e)).toList();
  }

  // ================= TRENDING USERS =================
  static Future<List<User>> getTrendingUsers() async {
    final res = await HttpService.get(
      '${Api.searchEndpoint}/trending/users',
    );

    if (res == null || res is! List) return [];

    return res.map<User>((e) => User.fromJson(e)).toList();
  }
}

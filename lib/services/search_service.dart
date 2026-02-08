import '../core/api.dart';
import '../core/http_service.dart';

class SearchService {
  // ================= SEARCH USERS =================
  // Ҷустуҷӯи корбарон аз рӯи username / name
  static Future<List<dynamic>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final res = await HttpService.get(
      '${Api.searchEndpoint}/users?q=$query',
    );

    return res is List ? res : [];
  }

  // ================= SEARCH POSTS =================
  // Ҷустуҷӯи постҳо (caption, hashtag)
  static Future<List<dynamic>> searchPosts(String query) async {
    if (query.trim().isEmpty) return [];

    final res = await HttpService.get(
      '${Api.searchEndpoint}/posts?q=$query',
    );

    return res is List ? res : [];
  }

  // ================= SEARCH REELS =================
  // Ҷустуҷӯи reels
  static Future<List<dynamic>> searchReels(String query) async {
    if (query.trim().isEmpty) return [];

    final res = await HttpService.get(
      '${Api.searchEndpoint}/reels?q=$query',
    );

    return res is List ? res : [];
  }

  // ================= TRENDING POSTS =================
  // Постҳои тренд (барои grid мисли Instagram)
  static Future<List<dynamic>> getTrendingPosts() async {
    final res = await HttpService.get(
      '${Api.searchEndpoint}/trending',
    );

    return res is List ? res : [];
  }

  // ================= SUGGESTED USERS =================
  // Корбарони тавсияшаванда
  static Future<List<dynamic>> getSuggestedUsers() async {
    final res = await HttpService.get(
      '${Api.searchEndpoint}/suggested',
    );

    return res is List ? res : [];
  }
}

// lib/services/search_service.dart

import '../core/api.dart';
import '../core/http_service.dart';

class SearchService {
  // =========================
  // GLOBAL SEARCH
  // q = keyword
  // =========================
  static Future<Map<String, dynamic>> search(String query) async {
    if (query.trim().isEmpty) {
      return {
        'users': [],
        'posts': [],
        'reels': [],
        'hashtags': [],
      };
    }

    final res = await HttpService.get(
      '${Api.search}?q=${Uri.encodeComponent(query)}',
      auth: true,
    );

    if (res is Map<String, dynamic>) {
      return {
        'users': res['users'] ?? [],
        'posts': res['posts'] ?? [],
        'reels': res['reels'] ?? [],
        'hashtags': res['hashtags'] ?? [],
      };
    }

    return {
      'users': [],
      'posts': [],
      'reels': [],
      'hashtags': [],
    };
  }

  // =========================
  // SEARCH USERS ONLY
  // =========================
  static Future<List<dynamic>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final res = await HttpService.get(
      '${Api.search}/users?q=${Uri.encodeComponent(query)}',
      auth: true,
    );

    if (res is List) return res;
    return [];
  }

  // =========================
  // SEARCH POSTS ONLY
  // =========================
  static Future<List<dynamic>> searchPosts(String query) async {
    if (query.trim().isEmpty) return [];

    final res = await HttpService.get(
      '${Api.search}/posts?q=${Uri.encodeComponent(query)}',
      auth: true,
    );

    if (res is List) return res;
    return [];
  }

  // =========================
  // SEARCH REELS ONLY
  // =========================
  static Future<List<dynamic>> searchReels(String query) async {
    if (query.trim().isEmpty) return [];

    final res = await HttpService.get(
      '${Api.search}/reels?q=${Uri.encodeComponent(query)}',
      auth: true,
    );

    if (res is List) return res;
    return [];
  }

  // =========================
  // SEARCH BY HASHTAG
  // =========================
  static Future<List<dynamic>> searchHashtag(String hashtag) async {
    if (hashtag.trim().isEmpty) return [];

    final tag = hashtag.replaceAll('#', '');

    final res = await HttpService.get(
      '${Api.search}/hashtag/$tag',
      auth: true,
    );

    if (res is List) return res;
    return [];
  }

  // =========================
  // TRENDING SEARCH (EXPLORE)
  // =========================
  static Future<List<dynamic>> getTrending() async {
    final res = await HttpService.get(
      '${Api.search}/trending',
      auth: true,
    );

    if (res is List) return res;
    return [];
  }
}

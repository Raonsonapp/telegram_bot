// lib/services/search_service.dart
// =====================================================
// SEARCH SERVICE – FIXED v5
// Fully compatible with Api.dart
// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';

class SearchService {
  // =========================
  // GLOBAL SEARCH
  // =========================
  // GET /search?q=keyword
  static Future<Map<String, dynamic>> search(String query) async {
    if (query.trim().isEmpty) {
      return _emptyResult();
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

    return _emptyResult();
  }

  // =========================
  // SEARCH USERS
  // =========================
  // GET /search/users?q=
  static Future<List<dynamic>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final res = await HttpService.get(
      Api.searchUsers(Uri.encodeComponent(query)),
      auth: true,
    );

    return res is List ? res : [];
  }

  // =========================
  // SEARCH POSTS
  // =========================
  // GET /search/posts?q=
  static Future<List<dynamic>> searchPosts(String query) async {
    if (query.trim().isEmpty) return [];

    final res = await HttpService.get(
      Api.searchPosts(Uri.encodeComponent(query)),
      auth: true,
    );

    return res is List ? res : [];
  }

  // =========================
  // SEARCH HASHTAGS
  // =========================
  // GET /search/hashtags?q=
  static Future<List<dynamic>> searchHashtags(String query) async {
    if (query.trim().isEmpty) return [];

    final clean = query.replaceAll('#', '');

    final res = await HttpService.get(
      Api.searchHashtags(Uri.encodeComponent(clean)),
      auth: true,
    );

    return res is List ? res : [];
  }

  // =========================
  // INTERNAL
  // =========================
  static Map<String, dynamic> _emptyResult() {
    return {
      'users': [],
      'posts': [],
      'reels': [],
      'hashtags': [],
    };
  }
}

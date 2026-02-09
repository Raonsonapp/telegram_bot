/// lib/services/post_service.dart
/// =====================================================
/// POST SERVICE – FINAL v5 (FIXED)
/// Handles:
/// - Feed posts
/// - User posts
/// - Create / Delete post
/// - Like / Unlike
/// - Save / Unsave
/// - Comments
/// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/post.dart';
import '../models/comment.dart';

class PostService {
  // =====================================================
  // GET FEED POSTS (HOME)
  // =====================================================

  static Future<List<Post>> getFeed() async {
    final res = await HttpService.get(
      Api.feedPosts,
      auth: true,
    );

    if (res is! List) {
      return [];
    }

    return res
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }

  // =====================================================
  // GET USER POSTS
  // =====================================================

  static Future<List<Post>> getByUser(String username) async {
    final res = await HttpService.get(
      Api.userPosts(username),
      auth: true,
    );

    if (res is! List) {
      return [];
    }

    return res
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }

  // =====================================================
  // CREATE POST
  // =====================================================

  static Future<Post> create({
    required String mediaUrl,
    String? caption,
  }) async {
    final res = await HttpService.post(
      Api.createPost,
      body: {
        'media_url': mediaUrl,
        if (caption != null) 'caption': caption,
      },
      auth: true,
    );

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid create post response');
    }

    return Post.fromJson(res);
  }

  // =====================================================
  // DELETE POST
  // =====================================================

  static Future<void> delete(int postId) async {
    await HttpService.delete(
      Api.deletePost(postId),
      auth: true,
    );
  }

  // =====================================================
  // LIKE POST
  // =====================================================

  static Future<void> like(int postId) async {
    await HttpService.post(
      Api.likePost(postId),
      body: const {},
      auth: true,
    );
  }

  // =====================================================
  // UNLIKE POST
  // =====================================================

  static Future<void> unlike(int postId) async {
    await HttpService.post(
      Api.unlikePost(postId),
      body: const {},
      auth: true,
    );
  }

  // =====================================================
  // SAVE POST
  // =====================================================

  static Future<void> save(int postId) async {
    await HttpService.post(
      Api.savePost(postId),
      body: const {},
      auth: true,
    );
  }

  // =====================================================
  // UNSAVE POST
  // =====================================================

  static Future<void> unsave(int postId) async {
    await HttpService.post(
      Api.unsavePost(postId),
      body: const {},
      auth: true,
    );
  }

  // =====================================================
  // GET COMMENTS
  // =====================================================

  static Future<List<Comment>> getComments(int postId) async {
    final res = await HttpService.get(
      Api.getComments(postId),
      auth: true,
    );

    if (res is! List) {
      return [];
    }

    return res
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }

  // =====================================================
  // ADD COMMENT
  // =====================================================

  static Future<Comment> addComment({
    required int postId,
    required String text,
  }) async {
    final res = await HttpService.post(
      Api.addComment(postId),
      body: {'text': text},
      auth: true,
    );

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid add comment response');
    }

    return Comment.fromJson(res);
  }
}

/// lib/services/post_service.dart
/// =====================================================
/// POST SERVICE – FINAL v5
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

    return (res as List)
        .map((e) => Post.fromJson(e))
        .toList();
  }

  // =====================================================
  // GET USER POSTS
  // =====================================================

  static Future<List<Post>> getByUser(String username) async {
    final res = await HttpService.get(
      '${Api.userPosts}/$username',
      auth: true,
    );

    return (res as List)
        .map((e) => Post.fromJson(e))
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

    return Post.fromJson(res);
  }

  // =====================================================
  // DELETE POST
  // =====================================================

  static Future<void> delete(int postId) async {
    await HttpService.delete(
      '${Api.deletePost}/$postId',
      auth: true,
    );
  }

  // =====================================================
  // LIKE POST
  // =====================================================

  static Future<void> like(int postId) async {
    await HttpService.post(
      '${Api.likePost}/$postId',
      body: {},
      auth: true,
    );
  }

  // =====================================================
  // UNLIKE POST
  // =====================================================

  static Future<void> unlike(int postId) async {
    await HttpService.post(
      '${Api.unlikePost}/$postId',
      body: {},
      auth: true,
    );
  }

  // =====================================================
  // SAVE POST
  // =====================================================

  static Future<void> save(int postId) async {
    await HttpService.post(
      '${Api.savePost}/$postId',
      body: {},
      auth: true,
    );
  }

  // =====================================================
  // UNSAVE POST
  // =====================================================

  static Future<void> unsave(int postId) async {
    await HttpService.post(
      '${Api.unsavePost}/$postId',
      body: {},
      auth: true,
    );
  }

  // =====================================================
  // GET COMMENTS
  // =====================================================

  static Future<List<Comment>> getComments(int postId) async {
    final res = await HttpService.get(
      '${Api.comments}/$postId',
      auth: true,
    );

    return (res as List)
        .map((e) => Comment.fromJson(e))
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
      '${Api.addComment}/$postId',
      body: {'text': text},
      auth: true,
    );

    return Comment.fromJson(res);
  }
}

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/post.dart';
import '../models/story.dart';

class PostService {
  // ===== FEED POSTS =====
  static Future<List<Post>> getFeedPosts() async {
    final res = await HttpService.get(Api.postsEndpoint);
    if (res == null) return [];

    return List<Post>.from(
      res.map((e) => Post.fromJson(e)),
    );
  }

  // ===== CREATE POST =====
  static Future<void> createPost({
    required String mediaUrl,
    String? caption,
  }) async {
    await HttpService.post(
      Api.postsEndpoint,
      {
        'media_url': mediaUrl,
        'caption': caption,
      },
    );
  }

  // ===== LIKE / UNLIKE =====
  static Future<void> likePost(int postId) async {
    await HttpService.post(
      '${Api.postsEndpoint}/$postId/like',
      {},
    );
  }

  static Future<void> unlikePost(int postId) async {
    await HttpService.post(
      '${Api.postsEndpoint}/$postId/unlike',
      {},
    );
  }

  // ===== SAVE / UNSAVE =====
  static Future<void> savePost(int postId) async {
    await HttpService.post(
      '${Api.postsEndpoint}/$postId/save',
      {},
    );
  }

  static Future<void> unsavePost(int postId) async {
    await HttpService.post(
      '${Api.postsEndpoint}/$postId/unsave',
      {},
    );
  }

  // ===== STORIES =====
  static Future<void> createStory(String mediaUrl) async {
    await HttpService.post(
      Api.storiesEndpoint,
      {'media_url': mediaUrl},
    );
  }

  static Future<List<Story>> getStories() async {
    final res = await HttpService.get(Api.storiesEndpoint);
    if (res == null) return [];

    return List<Story>.from(
      res.map((e) => Story.fromJson(e)),
    );
  }

  // ===== REELS =====
  static Future<List<Post>> getReels() async {
    final res = await HttpService.get(Api.reelsEndpoint);
    if (res == null) return [];

    return List<Post>.from(
      res.map((e) => Post.fromJson(e)),
    );
  }
}

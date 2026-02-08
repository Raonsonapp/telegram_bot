import '../core/api.dart';
import '../core/http_service.dart';
import '../models/post.dart';
import '../models/story.dart';
import '../models/reel.dart';

class PostService {
  // ================= FEED =================
  static Future<List<Post>> getFeedPosts() async {
    final res = await HttpService.get(Api.postsEndpoint);
    if (res == null || res is! List) return [];
    return res.map<Post>((e) => Post.fromJson(e)).toList();
  }

  // ================= CREATE POST =================
  static Future<Post> createPost({
    required String mediaUrl,
    required String caption,
  }) async {
    final res = await HttpService.post(
      Api.postsEndpoint,
      {
        'media_url': mediaUrl,
        'caption': caption,
      },
    );

    if (res == null) {
      throw Exception('Create post failed');
    }
    return Post.fromJson(res);
  }

  // ================= DELETE POST =================
  static Future<void> deletePost(int postId) async {
    await HttpService.delete('${Api.postsEndpoint}/$postId');
  }

  // ================= LIKE =================
  static Future<void> likePost(int postId) async {
    await HttpService.post(
      '${Api.postsEndpoint}/$postId/like',
      {},
    );
  }

  // ================= UNLIKE =================
  static Future<void> unlikePost(int postId) async {
    await HttpService.post(
      '${Api.postsEndpoint}/$postId/unlike',
      {},
    );
  }

  // ================= COMMENTS =================
  static Future<List<Map<String, dynamic>>> getComments(int postId) async {
    final res =
        await HttpService.get('${Api.postsEndpoint}/$postId/comments');
    if (res == null || res is! List) return [];
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<void> addComment({
    required int postId,
    required String text,
  }) async {
    await HttpService.post(
      '${Api.postsEndpoint}/$postId/comments',
      {'text': text},
    );
  }

  // ================= STORIES =================
  static Future<List<Story>> getStories() async {
    final res = await HttpService.get(Api.storiesEndpoint);
    if (res == null || res is! List) return [];
    return res.map<Story>((e) => Story.fromJson(e)).toList();
  }

  static Future<Story> createStory({
    required String mediaUrl,
  }) async {
    final res = await HttpService.post(
      Api.storiesEndpoint,
      {'media_url': mediaUrl},
    );

    if (res == null) {
      throw Exception('Create story failed');
    }
    return Story.fromJson(res);
  }

  // ================= REELS =================
  static Future<List<Reel>> getReels() async {
    final res = await HttpService.get(Api.reelsEndpoint);
    if (res == null || res is! List) return [];
    return res.map<Reel>((e) => Reel.fromJson(e)).toList();
  }

  static Future<Reel> createReel({
    required String mediaUrl,
    required String caption,
  }) async {
    final res = await HttpService.post(
      Api.reelsEndpoint,
      {
        'media_url': mediaUrl,
        'caption': caption,
      },
    );

    if (res == null) {
      throw Exception('Create reel failed');
    }
    return Reel.fromJson(res);
  }
}

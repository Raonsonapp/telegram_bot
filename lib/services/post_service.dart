import '../core/api.dart';
import '../core/http_service.dart';
import '../models/post.dart';
import '../models/story.dart';
import '../models/reel.dart';

class PostService {
  // ================= FEED POSTS =================
  static Future<List<PostModel>> getFeedPosts() async {
    final response = await HttpService.get(Api.postsEndpoint);

    return (response as List)
        .map((json) => PostModel.fromJson(json))
        .toList();
  }

  // ================= CREATE POST =================
  static Future<PostModel> createPost({
    required String mediaUrl,
    required String caption,
  }) async {
    final response = await HttpService.post(
      Api.postsEndpoint,
      {
        'media_url': mediaUrl,
        'caption': caption,
      },
    );

    return PostModel.fromJson(response);
  }

  // ================= DELETE POST =================
  static Future<void> deletePost(int postId) async {
    await HttpService.delete('${Api.postsEndpoint}/$postId');
  }

  // ================= LIKE / UNLIKE =================
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

  // ================= COMMENTS =================
  static Future<List<Map<String, dynamic>>> getComments(int postId) async {
    final response =
        await HttpService.get('${Api.postsEndpoint}/$postId/comments');

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addComment({
    required int postId,
    required String text,
  }) async {
    await HttpService.post(
      '${Api.postsEndpoint}/$postId/comments',
      {
        'text': text,
      },
    );
  }

  // ================= STORIES =================
  static Future<List<StoryModel>> getStories() async {
    final response = await HttpService.get(Api.storiesEndpoint);

    return (response as List)
        .map((json) => StoryModel.fromJson(json))
        .toList();
  }

  static Future<StoryModel> createStory({
    required String mediaUrl,
  }) async {
    final response = await HttpService.post(
      Api.storiesEndpoint,
      {
        'media_url': mediaUrl,
      },
    );

    return StoryModel.fromJson(response);
  }

  // ================= REELS =================
  static Future<List<ReelModel>> getReels() async {
    final response = await HttpService.get(Api.reelsEndpoint);

    return (response as List)
        .map((json) => ReelModel.fromJson(json))
        .toList();
  }

  static Future<ReelModel> createReel({
    required String mediaUrl,
    required String caption,
  }) async {
    final response = await HttpService.post(
      Api.reelsEndpoint,
      {
        'media_url': mediaUrl,
        'caption': caption,
      },
    );

    return ReelModel.fromJson(response);
  }
}

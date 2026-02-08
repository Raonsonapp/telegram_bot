import '../core/api.dart';
import '../core/http_service.dart';
import '../models/post.dart';
import '../models/story.dart';

class PostService {
  // ===================== FEED =====================
  static Future<List<dynamic>> getFeedPosts() async {
    final res = await HttpService.get(Api.postsEndpoint);
    return res as List<dynamic>;
  }

  static Future<List<dynamic>> getReels() async {
    final res = await HttpService.get(Api.reelsEndpoint);
    return res as List<dynamic>;
  }

  static Future<List<dynamic>> getByUser(String username) async {
    final res = await HttpService.get(
      '${Api.postsEndpoint}/user/$username',
    );
    return res as List<dynamic>;
  }

  // ===================== CREATE =====================
  static Future<void> createPost({
    required String mediaUrl,
    required String caption,
  }) async {
    await HttpService.post(
      Api.postsEndpoint,
      {
        'media_url': mediaUrl,
        'caption': caption,
      },
    );
  }

  static Future<void> createReel({
    required String mediaUrl,
    required String caption,
  }) async {
    await HttpService.post(
      Api.reelsEndpoint,
      {
        'media_url': mediaUrl,
        'caption': caption,
      },
    );
  }

  static Future<void> deletePost(int postId) async {
    await HttpService.delete(
      '${Api.postsEndpoint}/$postId',
    );
  }

  // ===================== LIKES =====================
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

  // ===================== COMMENTS =====================
  static Future<List<dynamic>> getComments(int postId) async {
    final res = await HttpService.get(
      '${Api.postsEndpoint}/$postId/comments',
    );
    return res as List<dynamic>;
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

  // ===================== SAVED =====================
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

  static Future<List<dynamic>> getSavedPosts() async {
    final res = await HttpService.get(
      '${Api.postsEndpoint}/saved',
    );
    return res as List<dynamic>;
  }

  // ===================== STORIES =====================
  static Future<List<dynamic>> getStories() async {
    final res = await HttpService.get(Api.storiesEndpoint);
    return res as List<dynamic>;
  }

  static Future<void> createStory({
    required String mediaUrl,
  }) async {
    await HttpService.post(
      Api.storiesEndpoint,
      {'media_url': mediaUrl},
    );
  }

  static Future<void> markStoryViewed(int storyId) async {
    await HttpService.post(
      '${Api.storiesEndpoint}/$storyId/view',
      {},
    );
  }
}

import '../core/api.dart';
import '../core/http_service.dart';

class PostService {
  // FEED
  static Future<List<dynamic>> getFeedPosts() async {
    final res = await HttpService.get(Api.postsEndpoint);
    return res is List ? res : [];
  }

  // CREATE POST
  static Future<void> createPost({
    required String caption,
    required String mediaUrl,
  }) async {
    await HttpService.post(
      Api.postsEndpoint,
      {
        'caption': caption,
        'media_url': mediaUrl,
      },
    );
  }

  // LIKE / UNLIKE
  static Future<void> likePost(int postId) async {
    await HttpService.post(
      '${Api.postsEndpoint}/like',
      {'post_id': postId},
    );
  }

  static Future<void> unlikePost(int postId) async {
    await HttpService.post(
      '${Api.postsEndpoint}/unlike',
      {'post_id': postId},
    );
  }

  // COMMENTS
  static Future<List<dynamic>> getComments(int postId) async {
    final res = await HttpService.get(
      '${Api.postsEndpoint}/$postId/comments',
    );
    return res is List ? res : [];
  }

  static Future<void> addComment(int postId, String text) async {
    await HttpService.post(
      '${Api.postsEndpoint}/comment',
      {
        'post_id': postId,
        'text': text,
      },
    );
  }
}

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/story.dart';

class StoryService {
  // ================= GET ALL STORIES =================
  static Future<List<Story>> getStories() async {
    final res = await HttpService.get(Api.storiesEndpoint);

    if (res == null || res is! List) {
      return [];
    }

    return res.map<Story>((e) => Story.fromJson(e)).toList();
  }

  // ================= CREATE STORY =================
  static Future<Story> createStory({
    required String mediaUrl,
  }) async {
    final res = await HttpService.post(
      Api.storiesEndpoint,
      {
        'media_url': mediaUrl,
      },
    );

    if (res == null) {
      throw Exception('Create story failed');
    }

    return Story.fromJson(res);
  }

  // ================= MARK STORY AS VIEWED =================
  static Future<void> markViewed(int storyId) async {
    await HttpService.post(
      '${Api.storiesEndpoint}/$storyId/view',
      {},
    );
  }

  // ================= GET MY STORIES =================
  static Future<List<Story>> getMyStories() async {
    final res = await HttpService.get('${Api.storiesEndpoint}/me');

    if (res == null || res is! List) {
      return [];
    }

    return res.map<Story>((e) => Story.fromJson(e)).toList();
  }

  // ================= DELETE STORY =================
  static Future<void> deleteStory(int storyId) async {
    await HttpService.delete('${Api.storiesEndpoint}/$storyId');
  }
}

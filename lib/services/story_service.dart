import '../core/api.dart';
import '../core/http_service.dart';
import '../models/story.dart';

class StoryService {
  // ================= GET ALL STORIES =================
  static Future<List<StoryModel>> getStories() async {
    final response = await HttpService.get(Api.storiesEndpoint);

    return (response as List)
        .map((json) => StoryModel.fromJson(json))
        .toList();
  }

  // ================= CREATE STORY =================
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

  // ================= MARK STORY AS VIEWED =================
  static Future<void> markViewed(int storyId) async {
    await HttpService.post(
      '${Api.storiesEndpoint}/$storyId/view',
      {},
    );
  }

  // ================= DELETE STORY =================
  static Future<void> deleteStory(int storyId) async {
    await HttpService.delete(
      '${Api.storiesEndpoint}/$storyId',
    );
  }
}

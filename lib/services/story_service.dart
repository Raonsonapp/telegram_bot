import '../core/api.dart';
import '../core/http_service.dart';

class StoryService {
  // GET STORIES
  static Future<List<dynamic>> getStories() async {
    final res = await HttpService.get(Api.storiesEndpoint);
    return res is List ? res : [];
  }

  // CREATE STORY
  static Future<void> createStory(String mediaUrl) async {
    await HttpService.post(
      Api.storiesEndpoint,
      {'media_url': mediaUrl},
    );
  }

  // MARK AS VIEWED
  static Future<void> markViewed(int storyId) async {
    await HttpService.post(
      '${Api.storiesEndpoint}/view',
      {'story_id': storyId},
    );
  }
}

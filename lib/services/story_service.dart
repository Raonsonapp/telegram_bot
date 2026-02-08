import '../core/api.dart';
import '../core/http_service.dart';

class StoryService {
  static Future<List<dynamic>> getStories() async {
    return await HttpService.get(Api.storiesEndpoint);
  }

  static Future<void> markViewed(int storyId) async {
    await HttpService.post(
      '${Api.storiesEndpoint}/$storyId/view',
      {},
    );
  }
}

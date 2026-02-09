/// lib/services/story_service.dart
/// =====================================================
/// STORY SERVICE – FINAL v5 (FIXED)
/// Handles:
/// - Create story
/// - Get stories feed
/// - Mark story as viewed
/// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/story.dart';

class StoryService {
  // =====================================================
  // GET STORIES FEED
  // =====================================================

  static Future<List<Story>> getFeed() async {
    final res = await HttpService.get(
      Api.storiesFeed,
      auth: true,
    );

    if (res is! List) {
      return [];
    }

    return res
        .whereType<Map<String, dynamic>>()
        .map(Story.fromJson)
        .toList();
  }

  // =====================================================
  // CREATE STORY
  // =====================================================

  static Future<Story> create({
    required String mediaUrl,
  }) async {
    final res = await HttpService.post(
      Api.createStory,
      body: {
        'media_url': mediaUrl,
      },
      auth: true,
    );

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid create story response');
    }

    return Story.fromJson(res);
  }

  // =====================================================
  // MARK STORY AS VIEWED
  // =====================================================

  static Future<void> markViewed(int storyId) async {
    await HttpService.post(
      Api.viewStory(storyId),
      body: const {},
      auth: true,
    );
  }
}

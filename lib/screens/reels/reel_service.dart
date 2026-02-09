import '../core/api.dart';
import '../core/http_service.dart';

/// ReelService
/// --------------------------------------------------
/// Ҳамаи амалҳои Reels:
/// - feed
/// - create
/// - like / unlike
/// - save / unsave
/// - get saved reels
///
/// Version: v5 FULL
class ReelService {
  // =========================
  // GET REELS FEED
  // =========================
  static Future<List<dynamic>> getFeed() async {
    final res = await HttpService.get(
      Api.getReels,
      auth: true,
    );

    if (res is List) return res;
    return [];
  }

  // =========================
  // CREATE REEL
  // =========================
  static Future<void> create({
    required String videoUrl,
    String caption = '',
  }) async {
    await HttpService.post(
      Api.createReel,
      body: {
        'video_url': videoUrl,
        'caption': caption,
      },
      auth: true,
    );
  }

  // =========================
  // LIKE / UNLIKE
  // =========================
  static Future<void> like(int reelId) async {
    await HttpService.post(
      '${Api.likePost}/$reelId',
      auth: true,
    );
  }

  static Future<void> unlike(int reelId) async {
    await HttpService.post(
      '${Api.unlikePost}/$reelId',
      auth: true,
    );
  }

  // =========================
  // SAVE / UNSAVE
  // =========================
  static Future<void> save(int reelId) async {
    await HttpService.post(
      '${Api.savePost}/$reelId',
      auth: true,
    );
  }

  static Future<void> unsave(int reelId) async {
    await HttpService.post(
      '${Api.unsavePost}/$reelId',
      auth: true,
    );
  }

  // =========================
  // GET SAVED REELS
  // =========================
  static Future<List<dynamic>> getSaved() async {
    final res = await HttpService.get(
      '${Api.savePost}/saved',
      auth: true,
    );

    if (res is List) return res;
    return [];
  }
}

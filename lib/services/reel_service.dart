import '../core/api.dart';
import '../core/http_service.dart';
import '../models/reel.dart';

class ReelService {
  // ================= GET REELS FEED =================
  static Future<List<ReelModel>> getReels() async {
    final response = await HttpService.get(Api.reelsEndpoint);

    return (response as List)
        .map((json) => ReelModel.fromJson(json))
        .toList();
  }

  // ================= CREATE REEL =================
  static Future<ReelModel> createReel({
    required String videoUrl,
    String? caption,
  }) async {
    final response = await HttpService.post(
      Api.reelsEndpoint,
      {
        'video_url': videoUrl,
        'caption': caption,
      },
    );

    return ReelModel.fromJson(response);
  }

  // ================= LIKE REEL =================
  static Future<void> likeReel(int reelId) async {
    await HttpService.post(
      '${Api.reelsEndpoint}/$reelId/like',
      {},
    );
  }

  // ================= UNLIKE REEL =================
  static Future<void> unlikeReel(int reelId) async {
    await HttpService.post(
      '${Api.reelsEndpoint}/$reelId/unlike',
      {},
    );
  }

  // ================= SAVE REEL =================
  static Future<void> saveReel(int reelId) async {
    await HttpService.post(
      '${Api.reelsEndpoint}/$reelId/save',
      {},
    );
  }

  // ================= UNSAVE REEL =================
  static Future<void> unsaveReel(int reelId) async {
    await HttpService.post(
      '${Api.reelsEndpoint}/$reelId/unsave',
      {},
    );
  }
}

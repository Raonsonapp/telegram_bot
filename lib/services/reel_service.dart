import '../core/api.dart';
import '../core/http_service.dart';

class ReelService {
  // ================= GET REELS FEED =================
  static Future<List<dynamic>> getReels() async {
    final res = await HttpService.get(
      Api.reelsEndpoint,
    );
    return res is List ? res : [];
  }

  // ================= CREATE REEL =================
  static Future<void> createReel({
    required String mediaUrl,
    String caption = '',
  }) async {
    await HttpService.post(
      Api.reelsEndpoint,
      {
        'media_url': mediaUrl,
        'caption': caption,
      },
    );
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

  // ================= GET SAVED REELS =================
  static Future<List<dynamic>> getSavedReels() async {
    final res = await HttpService.get(
      '${Api.reelsEndpoint}/saved',
    );
    return res is List ? res : [];
  }
}

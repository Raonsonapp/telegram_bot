import '../core/api.dart';
import '../core/http_service.dart';
import '../models/reel.dart';

class ReelService {
  // ================= GET REELS FEED =================
  static Future<List<Reel>> getReels() async {
    final res = await HttpService.get(Api.reelsEndpoint);

    if (res == null || res is! List) {
      return [];
    }

    return res.map<Reel>((e) => Reel.fromJson(e)).toList();
  }

  // ================= CREATE REEL =================
  static Future<Reel> createReel({
    required String mediaUrl,
    String? caption,
  }) async {
    final res = await HttpService.post(
      Api.reelsEndpoint,
      {
        'media_url': mediaUrl,
        'caption': caption ?? '',
      },
    );

    if (res == null) {
      throw Exception('Create reel failed');
    }

    return Reel.fromJson(res);
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
  static Future<List<Reel>> getSavedReels() async {
    final res = await HttpService.get('${Api.reelsEndpoint}/saved');

    if (res == null || res is! List) {
      return [];
    }

    return res.map<Reel>((e) => Reel.fromJson(e)).toList();
  }

  // ================= DELETE REEL =================
  static Future<void> deleteReel(int reelId) async {
    await HttpService.delete('${Api.reelsEndpoint}/$reelId');
  }
}

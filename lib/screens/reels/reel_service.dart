import '../core/api.dart';
import '../core/http_service.dart';

class ReelService {
  // ================= GET REELS =================
  static Future<List<dynamic>> getReels() async {
    final res = await HttpService.get(Api.reelsEndpoint);
    return res is List ? res : [];
  }

  // ================= LIKE =================
  static Future<void> like(int reelId) async {
    await HttpService.post(
      '${Api.reelsEndpoint}/$reelId/like',
      {},
    );
  }

  // ================= UNLIKE =================
  static Future<void> unlike(int reelId) async {
    await HttpService.post(
      '${Api.reelsEndpoint}/$reelId/unlike',
      {},
    );
  }

  // ================= SAVE =================
  static Future<void> save(int reelId) async {
    await HttpService.post(
      '${Api.reelsEndpoint}/$reelId/save',
      {},
    );
  }

  // ================= UNSAVE =================
  static Future<void> unsave(int reelId) async {
    await HttpService.post(
      '${Api.reelsEndpoint}/$reelId/unsave',
      {},
    );
  }
}

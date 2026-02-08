import '../core/api.dart';
import '../core/http_service.dart';

class ReelService {
  static Future<List<dynamic>> getReels() async {
    return await HttpService.get(Api.reelsEndpoint);
  }

  static Future<void> like(int reelId) async {
    await HttpService.post(
      '${Api.reelsEndpoint}/$reelId/like',
      {},
    );
  }

  static Future<void> unlike(int reelId) async {
    await HttpService.post(
      '${Api.reelsEndpoint}/$reelId/unlike',
      {},
    );
  }

  static Future<void> save(int reelId) async {
    await HttpService.post(
      '${Api.reelsEndpoint}/$reelId/save',
      {},
    );
  }
}

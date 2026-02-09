/// lib/services/reel_service.dart
/// =====================================================
/// REEL SERVICE – FINAL v5
/// Handles:
/// - Get reels feed
/// - Create reel
/// - Like / Unlike reel
/// - Save / Unsave reel
/// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/reel.dart';

class ReelService {
  // =====================================================
  // GET REELS FEED
  // =====================================================

  static Future<List<Reel>> getFeed() async {
    final res = await HttpService.get(
      Api.getReels,
      auth: true,
    );

    return (res as List)
        .map((e) => Reel.fromJson(e))
        .toList();
  }

  // =====================================================
  // CREATE REEL
  // =====================================================

  static Future<Reel> create({
    required String videoUrl,
    String? caption,
  }) async {
    final res = await HttpService.post(
      Api.createReel,
      body: {
        'video_url': videoUrl,
        'caption': caption,
      },
      auth: true,
    );

    return Reel.fromJson(res);
  }

  // =====================================================
  // LIKE REEL
  // =====================================================

  static Future<void> like(int reelId) async {
    await HttpService.post(
      '${Api.likePost}/$reelId',
      body: {},
      auth: true,
    );
  }

  // =====================================================
  // UNLIKE REEL
  // =====================================================

  static Future<void> unlike(int reelId) async {
    await HttpService.post(
      '${Api.unlikePost}/$reelId',
      body: {},
      auth: true,
    );
  }

  // =====================================================
  // SAVE REEL
  // =====================================================

  static Future<void> save(int reelId) async {
    await HttpService.post(
      '${Api.savePost}/$reelId',
      body: {},
      auth: true,
    );
  }

  // =====================================================
  // UNSAVE REEL
  // =====================================================

  static Future<void> unsave(int reelId) async {
    await HttpService.post(
      '${Api.unsavePost}/$reelId',
      body: {},
      auth: true,
    );
  }
}

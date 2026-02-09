/// lib/services/reel_service.dart
/// =====================================================
/// REEL SERVICE – FINAL v5 (FIXED)
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
      Api.reelsFeed,
      auth: true,
    );

    if (res is! List) {
      return [];
    }

    return res
        .whereType<Map<String, dynamic>>()
        .map(Reel.fromJson)
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
        if (caption != null) 'caption': caption,
      },
      auth: true,
    );

    if (res is! Map<String, dynamic>) {
      throw Exception('Invalid create reel response');
    }

    return Reel.fromJson(res);
  }

  // =====================================================
  // LIKE REEL
  // =====================================================

  static Future<void> like(int reelId) async {
    await HttpService.post(
      Api.likeReel(reelId),
      body: const {},
      auth: true,
    );
  }

  // =====================================================
  // UNLIKE REEL
  // =====================================================

  static Future<void> unlike(int reelId) async {
    await HttpService.post(
      Api.unlikeReel(reelId),
      body: const {},
      auth: true,
    );
  }

  // =====================================================
  // SAVE REEL
  // =====================================================

  static Future<void> save(int reelId) async {
    await HttpService.post(
      Api.saveReel(reelId),
      body: const {},
      auth: true,
    );
  }

  // =====================================================
  // UNSAVE REEL
  // =====================================================

  static Future<void> unsave(int reelId) async {
    await HttpService.post(
      Api.unsaveReel(reelId),
      body: const {},
      auth: true,
    );
  }
}

/// lib/models/reel.dart
/// =====================================================
/// REEL MODEL – FINAL v5 (FIXED & SAFE)
/// Used in:
/// Reels feed, Reel player, Reel actions, Search
/// =====================================================

import 'user.dart';

class Reel {
  // ================= IDENTITY =================
  final int id;

  // ================= OWNER =================
  final User user;

  // ================= CONTENT =================
  final String videoUrl;
  final String? caption;

  // ================= STATS =================
  final int likesCount;
  final int commentsCount;
  final int viewsCount;

  // ================= STATE =================
  final bool isLiked;
  final bool isSaved;

  // ================= TIME =================
  final DateTime createdAt;

  // =====================================================
  // CONSTRUCTOR
  // =====================================================

  const Reel({
    required this.id,
    required this.user,
    required this.videoUrl,
    this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.isLiked,
    required this.isSaved,
    required this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['id'] as int,

      user: json['user'] != null
          ? User.fromJson(json['user'])
          : const User(
              id: 0,
              username: 'unknown',
              isVerified: false,
              followersCount: 0,
              followingCount: 0,
              postsCount: 0,
              isFollowing: false,
              createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            ),

      videoUrl: (json['video_url'] as String?) ?? '',
      caption: json['caption'],

      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,

      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,

      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // =====================================================
  // TO JSON (APP → BACKEND)
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'video_url': videoUrl,
      'caption': caption,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'views_count': viewsCount,
      'is_liked': isLiked,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // =====================================================
  // 🔧 UI / PLAYER HELPERS (IMPORTANT)
  // =====================================================

  /// video_player safety
  bool get hasVideo => videoUrl.trim().isNotEmpty;

  /// Always video (Reels)
  bool get isVideo => true;

  /// UI shortcuts
  String get username => user.username;
  String? get userAvatar => user.avatar;

  /// For grids / preview (future-proof)
  String? get thumbnail => null;

  // =====================================================
  // COPY WITH (STATE SAFE)
  // =====================================================

  Reel copyWith({
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    bool? isLiked,
    bool? isSaved,
  }) {
    return Reel(
      id: id,
      user: user,
      videoUrl: videoUrl,
      caption: caption,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'Reel(id: $id, user: ${user.username}, likes: $likesCount)';
  }
}

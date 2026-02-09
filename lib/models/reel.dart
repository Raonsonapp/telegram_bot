/// lib/models/reel.dart
/// =====================================================
/// REEL MODEL – FINAL v5.1 (BUILD SAFE)
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
  final String caption;

  // ================= STATS =================
  final int likesCount;
  final int commentsCount;
  final int viewsCount;

  // ================= STATE =================
  final bool isLiked;
  final bool isSaved;

  // ================= TIME =================
  final DateTime? createdAt;

  const Reel({
    required this.id,
    required this.user,
    required this.videoUrl,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.isLiked,
    required this.isSaved,
    this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================
  factory Reel.fromJson(Map<String, dynamic> json) {
    final media =
        json['video_url'] ??
        json['media_url'] ??
        '';

    return Reel(
      id: json['id'] as int,

      user: json['user'] != null
          ? User.fromJson(json['user'])
          : User(
              id: -1,
              username: 'unknown',
              isVerified: false,
              followersCount: 0,
              followingCount: 0,
              postsCount: 0,
              isFollowing: false,
              createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            ),

      videoUrl: media as String,
      caption: (json['caption'] as String?) ?? '',

      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,

      isLiked: json['is_liked'] == true,
      isSaved: json['is_saved'] == true,

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  // =====================================================
  // TO JSON
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
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // =====================================================
  // UI / PLAYER HELPERS
  // =====================================================
  bool get hasVideo => videoUrl.trim().isNotEmpty;

  bool get isVideo => true;

  String get username => user.username;
  String? get userAvatar => user.avatar;

  /// Used in search & grids (fallback)
  String get thumbnail => videoUrl;

  // =====================================================
  // COPY WITH
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

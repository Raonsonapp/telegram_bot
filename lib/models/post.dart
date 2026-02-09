/// lib/models/post.dart
/// =====================================================
/// POST MODEL – FINAL v5.1 (BUILD SAFE)
/// Compatible with UI, Search, Reels, Services
/// =====================================================

import 'user.dart';

class Post {
  // ================= IDENTITY =================
  final int id;

  // ================= OWNER =================
  final User user;

  // ================= CONTENT =================
  final String mediaUrl; // image or video
  final String caption;

  // ================= STATS =================
  final int likesCount;
  final int commentsCount;

  // ================= USER STATE =================
  final bool isLiked;
  final bool isSaved;

  // ================= META =================
  final DateTime? createdAt;

  const Post({
    required this.id,
    required this.user,
    required this.mediaUrl,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isSaved,
    this.createdAt,
  });

  // =====================================================
  // FROM JSON
  // =====================================================
  factory Post.fromJson(Map<String, dynamic> json) {
    final media =
        json['media_url'] ??
        json['video_url'] ??
        '';

    return Post(
      id: json['id'] as int,

      user: User.fromJson(json['user'] as Map<String, dynamic>),

      mediaUrl: media as String,
      caption: (json['caption'] as String?) ?? '',

      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,

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
      'media_url': mediaUrl,
      'caption': caption,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
      'is_saved': isSaved,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // =====================================================
  // COPY WITH
  // =====================================================
  Post copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
  }) {
    return Post(
      id: id,
      user: user,
      mediaUrl: mediaUrl,
      caption: caption,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt,
    );
  }

  // =====================================================
  // UI HELPERS (CRITICAL)
  // =====================================================
  String get username => user.username;
  String? get avatar => user.avatar;

  /// Used in grids & previews
  String get mediaThumbnail => mediaUrl;

  bool get hasCaption => caption.trim().isNotEmpty;

  bool get isVideo =>
      mediaUrl.toLowerCase().endsWith('.mp4') ||
      mediaUrl.toLowerCase().endsWith('.mov') ||
      mediaUrl.toLowerCase().endsWith('.webm');

  bool get isImage => !isVideo;

  /// 🔥 REQUIRED BY SEARCH / GRID / UI
  bool get isReel => isVideo;

  @override
  String toString() {
    return 'Post(id: $id, user: ${user.username})';
  }
}

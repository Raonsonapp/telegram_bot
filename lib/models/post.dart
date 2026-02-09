/// lib/models/post.dart
/// =====================================================
/// POST MODEL – FINAL v5
/// Used in:
/// Feed, Profile, Search, Comments
/// =====================================================

import 'user.dart';

class Post {
  // ================= IDENTITY =================
  final int id;

  // ================= OWNER =================
  final User user;

  // ================= CONTENT =================
  final String mediaUrl; // image or video
  final String? caption;

  // ================= STATS =================
  final int likesCount;
  final int commentsCount;

  // ================= USER STATE =================
  final bool isLiked;
  final bool isSaved;

  // ================= META =================
  final DateTime createdAt;

  // =====================================================
  // CONSTRUCTOR
  // =====================================================

  const Post({
    required this.id,
    required this.user,
    required this.mediaUrl,
    this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isSaved,
    required this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,

      user: User.fromJson(json['user']),

      mediaUrl: json['media_url'] as String,
      caption: json['caption'],

      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,

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
      'media_url': mediaUrl,
      'caption': caption,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // =====================================================
  // COPY WITH (STATE UPDATE SAFE)
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
  // HELPERS
  // =====================================================

  bool get hasCaption =>
      caption != null && caption!.isNotEmpty;

  bool get isVideo =>
      mediaUrl.toLowerCase().endsWith('.mp4') ||
      mediaUrl.toLowerCase().endsWith('.mov') ||
      mediaUrl.toLowerCase().endsWith('.webm');

  bool get isImage => !isVideo;

  @override
  String toString() {
    return 'Post(id: $id, user: ${user.username})';
  }
}

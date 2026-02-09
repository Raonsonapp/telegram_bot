/// lib/models/story.dart
/// =====================================================
/// STORY MODEL – FINAL v5.1 (BUILD SAFE)
/// Used in:
/// StoryBar, StoryViewer
/// =====================================================

import 'user.dart';

class Story {
  // ================= IDENTITY =================
  final int id;

  // ================= OWNER =================
  final User user;

  // ================= CONTENT =================
  final String mediaUrl;

  // ================= STATE =================
  final bool isViewed;

  // ================= TIME =================
  final DateTime? createdAt;
  final DateTime? expiresAt;

  const Story({
    required this.id,
    required this.user,
    required this.mediaUrl,
    required this.isViewed,
    this.createdAt,
    this.expiresAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================
  factory Story.fromJson(Map<String, dynamic> json) {
    final media =
        json['media_url'] ??
        json['media'] ??
        json['mediaUrl'] ??
        '';

    return Story(
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

      mediaUrl: media as String,

      isViewed: json['is_viewed'] == true,

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,

      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
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
      'is_viewed': isViewed,
      'created_at': createdAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  // =====================================================
  // 🔧 UI HELPERS (VERY IMPORTANT)
  // =====================================================

  /// Used in StoryBar / Viewer
  String get username => user.username;
  String? get avatar => user.avatar;

  /// Expiry check (safe)
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Media type
  bool get isVideo =>
      mediaUrl.toLowerCase().endsWith('.mp4') ||
      mediaUrl.toLowerCase().endsWith('.mov') ||
      mediaUrl.toLowerCase().endsWith('.webm');

  bool get isImage => !isVideo;

  bool get hasMedia => mediaUrl.trim().isNotEmpty;

  // =====================================================
  // COPY WITH
  // =====================================================
  Story copyWith({
    bool? isViewed,
  }) {
    return Story(
      id: id,
      user: user,
      mediaUrl: mediaUrl,
      isViewed: isViewed ?? this.isViewed,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  @override
  String toString() {
    return 'Story(id: $id, user: ${user.username}, viewed: $isViewed)';
  }
}

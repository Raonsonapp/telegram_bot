/// lib/models/story.dart
/// =====================================================
/// STORY MODEL – FINAL v5
/// Used in:
/// StoryBar, Story Viewer
/// =====================================================

import 'user.dart';

class Story {
  // ================= IDENTITY =================
  final int id;

  // ================= OWNER =================
  final User user;

  // ================= CONTENT =================
  final String mediaUrl; // image or video

  // ================= STATE =================
  final bool isViewed;

  // ================= TIME =================
  final DateTime createdAt;
  final DateTime expiresAt;

  // =====================================================
  // CONSTRUCTOR
  // =====================================================

  const Story({
    required this.id,
    required this.user,
    required this.mediaUrl,
    required this.isViewed,
    required this.createdAt,
    required this.expiresAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as int,

      user: User.fromJson(json['user']),

      mediaUrl: json['media_url'] as String,

      isViewed: json['is_viewed'] ?? false,

      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
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
      'is_viewed': isViewed,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  // =====================================================
  // HELPERS
  // =====================================================

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isVideo =>
      mediaUrl.toLowerCase().endsWith('.mp4') ||
      mediaUrl.toLowerCase().endsWith('.mov') ||
      mediaUrl.toLowerCase().endsWith('.webm');

  bool get isImage => !isVideo;

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

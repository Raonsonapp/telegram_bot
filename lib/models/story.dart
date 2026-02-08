class Story {
  final int id;
  final int userId;
  final String username;
  final String? userAvatar;
  final String mediaUrl;
  final DateTime expiresAt;
  final bool isViewed;

  Story({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.mediaUrl,
    required this.expiresAt,
    required this.isViewed,
  });

  // ===== FROM JSON =====
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'],
      userAvatar: json['user_avatar'],
      mediaUrl: json['media_url'],
      expiresAt: DateTime.parse(json['expires_at']),
      isViewed: json['is_viewed'] ?? false,
    );
  }

  // ===== TO JSON =====
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'user_avatar': userAvatar,
      'media_url': mediaUrl,
      'expires_at': expiresAt.toIso8601String(),
      'is_viewed': isViewed,
    };
  }
}

class Post {
  final int id;
  final int userId;
  final String username;
  final String? userAvatar;
  final String mediaUrl;
  final String? caption;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.mediaUrl,
    this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isSaved,
    required this.createdAt,
  });

  // ===== FROM JSON =====
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'],
      userAvatar: json['user_avatar'],
      mediaUrl: json['media_url'],
      caption: json['caption'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
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
      'caption': caption,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

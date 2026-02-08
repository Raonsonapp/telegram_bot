import 'user.dart';

class Post {
  final int id;
  final User user;

  final String mediaUrl; // image / video
  final String mediaType; // image | video | reel

  final String caption;

  final int likesCount;
  final int commentsCount;

  final bool isLiked;
  final bool isSaved;

  final DateTime createdAt;

  const Post({
    required this.id,
    required this.user,
    required this.mediaUrl,
    required this.mediaType,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isSaved,
    required this.createdAt,
  });

  // ================= FROM JSON =================
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] is String
          ? int.parse(json['id'])
          : json['id'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      mediaUrl: json['media_url'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      caption: json['caption'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] == true || json['is_liked'] == 1,
      isSaved: json['is_saved'] == true || json['is_saved'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.now(),
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'media_url': mediaUrl,
      'media_type': mediaType,
      'caption': caption,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ================= COPY WITH =================
  Post copyWith({
    int? id,
    User? user,
    String? mediaUrl,
    String? mediaType,
    String? caption,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ================= HELPERS =================
  bool get isVideo => mediaType == 'video' || mediaType == 'reel';

  bool get hasCaption => caption.isNotEmpty;

  String get shortCaption =>
      caption.length > 120 ? '${caption.substring(0, 120)}...' : caption;

  @override
  String toString() {
    return 'Post(id: $id, user: ${user.username})';
  }
}

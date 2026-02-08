import 'user.dart';

class Reel {
  final int id;
  final User user;

  final String videoUrl;
  final String caption;

  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;

  final DateTime createdAt;

  const Reel({
    required this.id,
    required this.user,
    required this.videoUrl,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isSaved,
    required this.createdAt,
  });

  // ================= FROM JSON =================
  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['id'] is String
          ? int.parse(json['id'])
          : json['id'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      videoUrl: json['video_url'] ?? '',
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
      'video_url': videoUrl,
      'caption': caption,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ================= COPY WITH =================
  Reel copyWith({
    int? id,
    User? user,
    String? videoUrl,
    String? caption,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
    DateTime? createdAt,
  }) {
    return Reel(
      id: id ?? this.id,
      user: user ?? this.user,
      videoUrl: videoUrl ?? this.videoUrl,
      caption: caption ?? this.caption,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ================= HELPERS =================
  Reel toggleLike() {
    return copyWith(
      isLiked: !isLiked,
      likesCount: isLiked ? likesCount - 1 : likesCount + 1,
    );
  }

  Reel toggleSave() {
    return copyWith(isSaved: !isSaved);
  }

  @override
  String toString() {
    return 'Reel(id: $id, user: ${user.username}, likes: $likesCount)';
  }
}

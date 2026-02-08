import 'user.dart';

class PostModel {
  final int id;
  final UserModel user;
  final String mediaUrl;
  final String? caption;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;

  PostModel({
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

  // ================= FROM JSON =================
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      mediaUrl: json['media_url'] ?? '',
      caption: json['caption'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // ================= TO JSON =================
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

  // ================= COPY WITH =================
  PostModel copyWith({
    int? id,
    UserModel? user,
    String? mediaUrl,
    String? caption,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      user: user ?? this.user,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

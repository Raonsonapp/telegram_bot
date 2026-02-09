/// lib/models/comment.dart
/// =====================================================
/// COMMENT MODEL – FINAL v5.1 (BUILD SAFE)
/// Used for:
/// - Post comments
/// - Reel comments
/// - Replies (nested)
/// =====================================================

import 'user.dart';

class Comment {
  // ================= IDENTITY =================
  final int id;

  // ================= AUTHOR =================
  final User user;

  // ================= TARGET =================
  final int targetId; // postId | reelId
  final String targetType; // 'post' | 'reel'

  // ================= CONTENT =================
  final String text;

  // ================= REPLY =================
  final int? parentId;
  final List<Comment> replies;

  // ================= STATS =================
  final int likesCount;
  final bool isLiked;

  // ================= TIME =================
  final DateTime? createdAt;

  const Comment({
    required this.id,
    required this.user,
    required this.targetId,
    required this.targetType,
    required this.text,
    this.parentId,
    this.replies = const [],
    required this.likesCount,
    required this.isLiked,
    this.createdAt,
  });

  // =====================================================
  // FROM JSON
  // =====================================================
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
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

      targetId: (json['target_id'] as int?) ??
          (json['post_id'] as int?) ??
          (json['reel_id'] as int?) ??
          0,

      targetType: (json['target_type'] as String?) ?? 'post',

      text: (json['text'] as String?) ?? '',

      parentId: json['parent_id'] as int?,

      replies: json['replies'] is List
          ? List<Comment>.from(
              (json['replies'] as List)
                  .map((e) => Comment.fromJson(e)),
            )
          : const [],

      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] == true,

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
      'target_id': targetId,
      'target_type': targetType,
      'text': text,
      'parent_id': parentId,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // =====================================================
  // 🔧 UI HELPERS
  // =====================================================
  bool get isReply => parentId != null;
  bool get hasReplies => replies.isNotEmpty;

  String get username => user.username;
  String? get avatar => user.avatar;

  bool get isPost => targetType == 'post';
  bool get isReel => targetType == 'reel';

  // =====================================================
  // COPY WITH
  // =====================================================
  Comment copyWith({
    int? likesCount,
    bool? isLiked,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id,
      user: user,
      targetId: targetId,
      targetType: targetType,
      text: text,
      parentId: parentId,
      replies: replies ?? this.replies,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, user: ${user.username}, replies: ${replies.length})';
  }
}

/// lib/models/comment.dart
/// =====================================================
/// COMMENT MODEL – FINAL v5 (FIXED & SAFE)
/// Used for:
/// - Post comments
/// - Reel comments
/// - Replies (nested comments)
/// =====================================================

import 'user.dart';

class Comment {
  // ================= IDENTITY =================
  final int id;

  // ================= AUTHOR =================
  final User user;

  // ================= TARGET =================
  final int targetId; // postId or reelId
  final String targetType; // 'post' | 'reel'

  // ================= CONTENT =================
  final String text;

  // ================= REPLY =================
  final int? parentId; // null = main comment
  final List<Comment> replies;

  // ================= STATS =================
  final int likesCount;
  final bool isLiked;

  // ================= TIME =================
  final DateTime createdAt;

  // =====================================================
  // CONSTRUCTOR
  // =====================================================

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
    required this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,

      user: json['user'] != null
          ? User.fromJson(json['user'])
          : const User(
              id: 0,
              username: 'unknown',
              isVerified: false,
              followersCount: 0,
              followingCount: 0,
              postsCount: 0,
              isFollowing: false,
              createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            ),

      targetId: json['target_id'] as int,
      targetType: (json['target_type'] as String?) ?? 'post',

      text: json['text'] ?? '',

      parentId: json['parent_id'],

      replies: json['replies'] is List
          ? List<Comment>.from(
              (json['replies'] as List)
                  .map((e) => Comment.fromJson(e)),
            )
          : const [],

      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,

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
      'target_id': targetId,
      'target_type': targetType,
      'text': text,
      'parent_id': parentId,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // =====================================================
  // 🔧 UI HELPERS (IMPORTANT)
  // =====================================================

  bool get isReply => parentId != null;
  bool get hasReplies => replies.isNotEmpty;

  String get username => user.username;
  String? get avatar => user.avatar;

  bool get isPost => targetType == 'post';
  bool get isReel => targetType == 'reel';

  // =====================================================
  // COPY WITH (STATE SAFE)
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

/// lib/models/like.dart
/// =====================================================
/// LIKE MODEL – FINAL v5 (FIXED & SAFE)
/// Used for:
/// - Post likes
/// - Reel likes
/// - Comment likes
/// =====================================================

import 'user.dart';

class Like {
  // ================= IDENTITY =================
  final int id;

  // ================= USER =================
  final User user;

  // ================= TARGET =================
  final int targetId; // postId | reelId | commentId
  final String targetType; // 'post' | 'reel' | 'comment'

  // ================= TIME =================
  final DateTime createdAt;

  // =====================================================
  // CONSTRUCTOR
  // =====================================================

  const Like({
    required this.id,
    required this.user,
    required this.targetId,
    required this.targetType,
    required this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
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
      targetType: _safeTargetType(json['target_type']),

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
      'created_at': createdAt.toIso8601String(),
    };
  }

  // =====================================================
  // 🔧 UI HELPERS
  // =====================================================

  String get username => user.username;
  String? get avatar => user.avatar;

  bool get isPost => targetType == 'post';
  bool get isReel => targetType == 'reel';
  bool get isComment => targetType == 'comment';

  // =====================================================
  // INTERNAL SAFETY
  // =====================================================

  static String _safeTargetType(dynamic value) {
    if (value == 'post' || value == 'reel' || value == 'comment') {
      return value;
    }
    return 'post';
  }

  @override
  String toString() {
    return 'Like(id: $id, user: ${user.username}, target: $targetType#$targetId)';
  }
}

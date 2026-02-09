/// lib/models/follow.dart
/// =====================================================
/// FOLLOW MODEL – FINAL v5 (FIXED & SAFE)
/// Used for:
/// - Followers list
/// - Following list
/// - Follow status
/// =====================================================

import 'user.dart';

class Follow {
  // ================= IDENTITY =================
  final int id;

  // ================= USERS =================
  /// User who follows
  final User follower;

  /// User being followed
  final User following;

  // ================= TIME =================
  final DateTime createdAt;

  // =====================================================
  // CONSTRUCTOR
  // =====================================================

  const Follow({
    required this.id,
    required this.follower,
    required this.following,
    required this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      id: json['id'] as int,

      follower: json['follower'] != null
          ? User.fromJson(json['follower'])
          : _emptyUser(),

      following: json['following'] != null
          ? User.fromJson(json['following'])
          : _emptyUser(),

      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // =====================================================
  // TO JSON (APP → BACKEND)
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower': follower.toJson(),
      'following': following.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // =====================================================
  // 🔧 UI HELPERS
  // =====================================================

  // follower
  String get followerUsername => follower.username;
  String? get followerAvatar => follower.avatar;
  bool get followerVerified => follower.isVerified;

  // following
  String get followingUsername => following.username;
  String? get followingAvatar => following.avatar;
  bool get followingVerified => following.isVerified;

  // =====================================================
  // INTERNAL SAFE USER
  // =====================================================

  static User _emptyUser() {
    return const User(
      id: 0,
      username: 'unknown',
      isVerified: false,
      followersCount: 0,
      followingCount: 0,
      postsCount: 0,
      isFollowing: false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  String toString() {
    return 'Follow(${follower.username} → ${following.username})';
  }
}

/// lib/models/follow.dart
/// =====================================================
/// FOLLOW MODEL – FINAL v5
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
      follower: User.fromJson(json['follower']),
      following: User.fromJson(json['following']),
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
  // HELPERS
  // =====================================================

  /// Username of follower
  String get followerUsername => follower.username;

  /// Username of followed user
  String get followingUsername => following.username;

  @override
  String toString() {
    return 'Follow($followerUsername → $followingUsername)';
  }
}

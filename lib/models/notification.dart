/// lib/models/notification.dart
/// =====================================================
/// NOTIFICATION MODEL – FINAL v5 (FIXED & SAFE)
/// Used for:
/// - Likes
/// - Comments
/// - Follows
/// - Messages
/// - System events
/// =====================================================

import 'user.dart';

/// Supported notification types
enum NotificationType {
  like,
  comment,
  follow,
  message,
  system,
}

class AppNotification {
  // ================= IDENTITY =================
  final int id;

  // ================= ACTOR =================
  /// User who triggered notification (can be system)
  final User fromUser;

  // ================= TARGET =================
  /// Optional post / reel / story / comment ID
  final int? targetId;

  /// Optional target type: post | reel | comment | story
  final String? targetType;

  // ================= CONTENT =================
  final NotificationType type;
  final String message;

  // ================= STATUS =================
  final bool isRead;

  // ================= TIME =================
  final DateTime createdAt;

  // =====================================================
  // CONSTRUCTOR
  // =====================================================

  const AppNotification({
    required this.id,
    required this.fromUser,
    required this.type,
    required this.message,
    this.targetId,
    this.targetType,
    required this.isRead,
    required this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,

      fromUser: json['from_user'] != null
          ? User.fromJson(json['from_user'])
          : _systemUser(),

      type: _parseType(json['type']),
      message: json['message'] ?? '',

      targetId: json['target_id'],
      targetType: json['target_type'],

      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // =====================================================
  // TO JSON (APP → BACKEND)
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user': fromUser.toJson(),
      'type': type.name,
      'message': message,
      'target_id': targetId,
      'target_type': targetType,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // =====================================================
  // HELPERS
  // =====================================================

  static NotificationType _parseType(dynamic type) {
    if (type is! String) return NotificationType.system;

    switch (type) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      case 'message':
        return NotificationType.message;
      default:
        return NotificationType.system;
    }
  }

  /// Human readable title (UI)
  String get title {
    switch (type) {
      case NotificationType.like:
        return 'Liked your post';
      case NotificationType.comment:
        return 'Commented on your post';
      case NotificationType.follow:
        return 'Started following you';
      case NotificationType.message:
        return 'New message';
      case NotificationType.system:
        return 'Notification';
    }
  }

  /// Actor username
  String get fromUsername => fromUser.username;

  /// Avatar helper
  String? get fromAvatar => fromUser.avatar;

  /// Is system notification
  bool get isSystem => type == NotificationType.system;

  // =====================================================
  // INTERNAL SYSTEM USER
  // =====================================================

  static User _systemUser() {
    return User(
      id: 0,
      username: 'Raonson',
      avatarUrl: null,
      bio: null,
      email: null,
      phone: null,
      isVerified: true,
      followersCount: 0,
      followingCount: 0,
      postsCount: 0,
      isFollowing: false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  String toString() {
    return 'Notification(type: $type, from: ${fromUser.username}, read: $isRead)';
  }
}

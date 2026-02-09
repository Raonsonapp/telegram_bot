/// lib/models/notification.dart
/// =====================================================
/// NOTIFICATION MODEL – FINAL v5
/// Used for:
/// - Likes
/// - Comments
/// - Follows
/// - Messages
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
  /// User who triggered notification
  final User fromUser;

  // ================= TARGET =================
  /// Optional post / reel / story ID
  final int? targetId;

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
    required this.isRead,
    required this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      fromUser: User.fromJson(json['from_user']),
      type: _parseType(json['type']),
      message: json['message'] ?? '',
      targetId: json['target_id'],
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
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // =====================================================
  // HELPERS
  // =====================================================

  static NotificationType _parseType(String? type) {
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

  /// Human readable title
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

  @override
  String toString() {
    return 'Notification($type from $fromUsername, read: $isRead)';
  }
}

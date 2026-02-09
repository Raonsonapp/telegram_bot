/// lib/models/notification.dart
/// =====================================================
/// NOTIFICATION MODEL – FINAL v5.1 (BUILD SAFE)
/// Compatible with NotificationsScreen & backend
/// =====================================================

import 'user.dart';

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
  final User fromUser;

  // ================= TARGET =================
  final int? targetId;
  final String? targetType;

  // ================= CONTENT =================
  final NotificationType type;
  final String message;

  // ================= STATUS =================
  final bool isRead;

  // ================= TIME =================
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.fromUser,
    required this.type,
    required this.message,
    this.targetId,
    this.targetType,
    required this.isRead,
    this.createdAt,
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

      targetId: json['target_id'] is int
          ? json['target_id']
          : int.tryParse('${json['target_id']}'),

      targetType: json['target_type'] as String?,

      isRead: json['is_read'] == true,

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
      'from_user': fromUser.toJson(),
      'type': type.name,
      'message': message,
      'target_id': targetId,
      'target_type': targetType,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // =====================================================
  // HELPERS (UI COMPATIBILITY)
  // =====================================================

  /// 🔧 Used by NotificationsScreen
  String get rawType => type.name;

  /// 🔧 Used by NotificationsScreen
  String get fromUsername => fromUser.username;

  /// 🔧 Used by NotificationsScreen
  bool get read => isRead;

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

  /// UI title
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

  String? get fromAvatar => fromUser.avatar;
  bool get isSystem => type == NotificationType.system;

  // =====================================================
  // INTERNAL SYSTEM USER
  // =====================================================
  static User _systemUser() {
    return User(
      id: -1,
      username: 'Raonson',
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
    return 'Notification(id: $id, type: $type, read: $isRead)';
  }
}

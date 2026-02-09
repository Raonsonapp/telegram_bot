/// lib/models/message.dart
/// =====================================================
/// MESSAGE MODEL – FINAL v5.1 (BUILD SAFE)
/// Used for:
/// - Chats
/// - Direct Messages
/// - Seen / Unseen logic
/// =====================================================

import 'user.dart';

class Message {
  // ================= IDENTITY =================
  final int id;

  // ================= USERS =================
  final User sender;
  final User receiver;

  // ================= CONTENT =================
  final String text;
  final String? mediaUrl;

  // ================= STATUS =================
  final bool isRead;

  // ================= TIME =================
  final DateTime? createdAt;

  const Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.text,
    this.mediaUrl,
    required this.isRead,
    this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,

      sender: json['sender'] != null
          ? User.fromJson(json['sender'])
          : _emptyUser(json['sender_id']),

      receiver: json['receiver'] != null
          ? User.fromJson(json['receiver'])
          : _emptyUser(json['receiver_id']),

      text: (json['text'] as String?) ?? '',

      mediaUrl: json['media_url'] is String
          ? json['media_url']
          : null,

      isRead: json['is_read'] == true,

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  // =====================================================
  // TO JSON (APP → BACKEND)
  // =====================================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'text': text,
      'media_url': mediaUrl,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // =====================================================
  // 🔧 UI HELPERS (CHAT)
  // =====================================================
  bool get hasMedia =>
      mediaUrl != null && mediaUrl!.trim().isNotEmpty;

  String get senderUsername => sender.username;
  String get receiverUsername => receiver.username;

  bool isFromUser(int myUserId) => sender.id == myUserId;

  String? get senderAvatar => sender.avatar;
  String? get receiverAvatar => receiver.avatar;

  // =====================================================
  // INTERNAL SAFE USER
  // =====================================================
  static User _emptyUser(dynamic id) {
    return User(
      id: id is int ? id : -1,
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
    return 'Message(id: $id, from: ${sender.username}, read: $isRead)';
  }
}

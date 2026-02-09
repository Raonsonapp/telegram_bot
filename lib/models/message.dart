/// lib/models/message.dart
/// =====================================================
/// MESSAGE MODEL – FINAL v5
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
  /// Sender of message
  final User sender;

  /// Receiver of message
  final User receiver;

  // ================= CONTENT =================
  final String text;

  /// Optional media (image / video / voice)
  final String? mediaUrl;

  // ================= STATUS =================
  final bool isRead;

  // ================= TIME =================
  final DateTime createdAt;

  // =====================================================
  // CONSTRUCTOR
  // =====================================================

  const Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.text,
    this.mediaUrl,
    required this.isRead,
    required this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
      text: json['text'] ?? '',
      mediaUrl: json['media_url'],
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
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'text': text,
      'media_url': mediaUrl,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // =====================================================
  // HELPERS
  // =====================================================

  /// True if message contains media
  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;

  /// Sender username
  String get senderUsername => sender.username;

  /// Receiver username
  String get receiverUsername => receiver.username;

  @override
  String toString() {
    return 'Message(from: $senderUsername → $receiverUsername, read: $isRead)';
  }
}

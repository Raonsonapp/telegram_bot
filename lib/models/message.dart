import 'user.dart';

class MessageModel {
  final int id;
  final int chatId;
  final UserModel sender;
  final String text;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.text,
    required this.isRead,
    required this.createdAt,
  });

  // ================= FROM JSON =================
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      chatId: json['chat_id'],
      sender: UserModel.fromJson(json['sender']),
      text: json['text'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender': sender.toJson(),
      'text': text,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ================= COPY WITH =================
  MessageModel copyWith({
    int? id,
    int? chatId,
    UserModel? sender,
    String? text,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ================= HELPERS =================
  bool get isMine => false; // дар UI бо username/session муайян мекунем
}

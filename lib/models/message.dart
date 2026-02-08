import 'user.dart';

class Message {
  final int id;

  final User sender;
  final User receiver;

  final String text;
  final String? mediaUrl; // image / video / voice (future-proof)
  final String type; // text | image | video | voice

  final bool isSeen;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.type,
    required this.isSeen,
    required this.createdAt,
    this.mediaUrl,
  });

  // ================= FROM JSON =================
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] is String
          ? int.parse(json['id'])
          : json['id'] ?? 0,
      sender: User.fromJson(json['sender'] ?? {}),
      receiver: User.fromJson(json['receiver'] ?? {}),
      text: json['text'] ?? '',
      mediaUrl: json['media_url'],
      type: json['type'] ?? 'text',
      isSeen: json['is_seen'] == true || json['is_seen'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.now(),
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'text': text,
      'media_url': mediaUrl,
      'type': type,
      'is_seen': isSeen,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ================= COPY WITH =================
  Message copyWith({
    int? id,
    User? sender,
    User? receiver,
    String? text,
    String? mediaUrl,
    String? type,
    bool? isSeen,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      type: type ?? this.type,
      isSeen: isSeen ?? this.isSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ================= HELPERS =================
  bool get isText => type == 'text';
  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isVoice => type == 'voice';

  Message markSeen() {
    return copyWith(isSeen: true);
  }

  bool isMine(String myUsername) {
    return sender.username == myUsername;
  }

  @override
  String toString() {
    return 'Message(id: $id, from: ${sender.username}, to: ${receiver.username})';
  }
}

class MessageModel {
  MessageModel({
    required this.id,
    required this.username,
    required this.lastMessage,
    this.avatarUrl = '',
    this.timeAgo = '',
  });

  final String id;
  final String username;
  final String lastMessage;
  final String avatarUrl;
  final String timeAgo;

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      lastMessage: map['lastMessage']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString() ?? '',
      timeAgo: map['timeAgo']?.toString() ?? '',
    );
  }
}

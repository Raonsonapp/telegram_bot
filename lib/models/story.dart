import 'user.dart';

class StoryModel {
  final int id;
  final UserModel user;
  final String mediaUrl;
  final DateTime expiresAt;
  final bool isViewed;

  StoryModel({
    required this.id,
    required this.user,
    required this.mediaUrl,
    required this.expiresAt,
    required this.isViewed,
  });

  // ================= FROM JSON =================
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      mediaUrl: json['media_url'] ?? '',
      expiresAt: DateTime.parse(json['expires_at']),
      isViewed: json['is_viewed'] ?? false,
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'media_url': mediaUrl,
      'expires_at': expiresAt.toIso8601String(),
      'is_viewed': isViewed,
    };
  }

  // ================= HELPERS =================
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  StoryModel copyWith({
    int? id,
    UserModel? user,
    String? mediaUrl,
    DateTime? expiresAt,
    bool? isViewed,
  }) {
    return StoryModel(
      id: id ?? this.id,
      user: user ?? this.user,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}

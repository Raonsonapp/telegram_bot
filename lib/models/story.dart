import 'user.dart';

class Story {
  final int id;
  final User user;

  final String mediaUrl; // image / video
  final String mediaType; // image | video

  final bool isViewed;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Story({
    required this.id,
    required this.user,
    required this.mediaUrl,
    required this.mediaType,
    required this.isViewed,
    required this.createdAt,
    required this.expiresAt,
  });

  // ================= FROM JSON =================
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] is String
          ? int.parse(json['id'])
          : json['id'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      mediaUrl: json['media_url'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      isViewed: json['is_viewed'] == true || json['is_viewed'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.now(),
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ??
          DateTime.now().add(const Duration(hours: 24)),
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'media_url': mediaUrl,
      'media_type': mediaType,
      'is_viewed': isViewed,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  // ================= COPY WITH =================
  Story copyWith({
    int? id,
    User? user,
    String? mediaUrl,
    String? mediaType,
    bool? isViewed,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Story(
      id: id ?? this.id,
      user: user ?? this.user,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      isViewed: isViewed ?? this.isViewed,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // ================= HELPERS =================
  bool get isVideo => mediaType == 'video';

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get timeLeft => expiresAt.difference(DateTime.now());

  @override
  String toString() {
    return 'Story(id: $id, user: ${user.username}, viewed: $isViewed)';
  }
}

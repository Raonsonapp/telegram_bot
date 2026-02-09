/// lib/models/user.dart
/// =====================================================
/// USER MODEL – FINAL v5.1 (BUILD SAFE)
/// Compatible with UI, Search, Follow, Chat
/// =====================================================

class User {
  // ================= IDENTITY =================
  final int id;
  final String username;
  final String? email;
  final String? phone;

  // ================= PROFILE =================
  final String? avatarUrl;
  final String? bio;
  final bool isVerified;

  // ================= STATS =================
  final int followersCount;
  final int followingCount;
  final int postsCount;

  // ================= RELATION =================
  final bool isFollowing;

  // ================= META =================
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.avatarUrl,
    this.bio,
    required this.isVerified,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.isFollowing,
    this.createdAt,
  });

  // =====================================================
  // FROM JSON
  // =====================================================
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,

      email: json['email'] as String?,
      phone: json['phone'] as String?,

      // support avatar OR avatar_url
      avatarUrl:
          json['avatar_url'] as String? ??
          json['avatar'] as String?,

      bio: json['bio'] as String?,

      isVerified: json['is_verified'] == true,

      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,

      isFollowing: json['is_following'] == true,

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
      'username': username,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_verified': isVerified,
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'is_following': isFollowing,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // =====================================================
  // COPY WITH
  // =====================================================
  User copyWith({
    String? username,
    String? avatarUrl,
    String? bio,
    bool? isVerified,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isFollowing,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isFollowing: isFollowing ?? this.isFollowing,
      createdAt: createdAt,
    );
  }

  // =====================================================
  // UI HELPERS
  // =====================================================
  String? get avatar => avatarUrl;

  bool get hasAvatar =>
      avatarUrl != null && avatarUrl!.trim().isNotEmpty;

  bool get hasBio =>
      bio != null && bio!.trim().isNotEmpty;

  String get displayName => username;

  @override
  String toString() {
    return 'User(id: $id, username: $username)';
  }
}

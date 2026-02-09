/// lib/models/user.dart
/// =====================================================
/// USER MODEL – FINAL v5
/// Used across the whole app:
/// Auth, Profile, Follow, Feed, Chat
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
  final bool isFollowing; // current user → this user

  // ================= META =================
  final DateTime createdAt;

  // =====================================================
  // CONSTRUCTOR
  // =====================================================

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
    required this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,

      email: json['email'],
      phone: json['phone'],

      avatarUrl: json['avatar_url'],
      bio: json['bio'],

      isVerified: json['is_verified'] == true,

      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,

      isFollowing: json['is_following'] ?? false,

      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // =====================================================
  // TO JSON (APP → BACKEND)
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
      'created_at': createdAt.toIso8601String(),
    };
  }

  // =====================================================
  // COPY WITH (STATE UPDATE SAFE)
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
  // HELPERS
  // =====================================================

  bool get hasAvatar =>
      avatarUrl != null && avatarUrl!.isNotEmpty;

  bool get hasBio =>
      bio != null && bio!.isNotEmpty;

  @override
  String toString() {
    return 'User(id: $id, username: $username)';
  }
}

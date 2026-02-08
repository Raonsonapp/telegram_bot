class User {
  final int id;
  final String username;
  final String? avatar;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final bool isVerified;

  User({
    required this.id,
    required this.username,
    this.avatar,
    this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.isVerified,
  });

  // ===== FROM JSON =====
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      avatar: json['avatar'],
      bio: json['bio'],
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      isVerified: json['is_verified'] ?? false,
    );
  }

  // ===== TO JSON =====
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'bio': bio,
      'followers_count': followersCount,
      'following_count': followingCount,
      'is_verified': isVerified,
    };
  }
}

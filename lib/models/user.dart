class User {
  final int id;
  final String username;
  final String email;
  final String? phone;
  final String? avatar;
  final String? bio;
  final bool isVerified;

  final int followersCount;
  final int followingCount;
  final int postsCount;

  final bool isFollowing; // оё ман ин user-ро follow кардаам

  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.avatar,
    this.bio,
    required this.isVerified,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.isFollowing,
    required this.createdAt,
  });

  // ================= FROM JSON =================
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is String
          ? int.parse(json['id'])
          : json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      isFollowing: json['is_following'] == true || json['is_following'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.now(),
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'is_verified': isVerified,
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'is_following': isFollowing,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ================= COPY WITH =================
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? phone,
    String? avatar,
    String? bio,
    bool? isVerified,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isFollowing,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isFollowing: isFollowing ?? this.isFollowing,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ================= HELPERS =================
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  String get displayName => '@$username';

  @override
  String toString() {
    return 'User(id: $id, username: $username)';
  }
}

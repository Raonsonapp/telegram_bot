class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    required this.avatarUrl,
    required this.followers,
    required this.following,
    required this.posts,
  });

  final String id;
  final String name;
  final String username;
  final String bio;
  final String avatarUrl;
  final int followers;
  final int following;
  final int posts;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString() ?? '',
      followers: map['followers'] is int ? map['followers'] as int : 0,
      following: map['following'] is int ? map['following'] as int : 0,
      posts: map['posts'] is int ? map['posts'] as int : 0,
    );
  }

  factory UserModel.empty() {
    return UserModel(
      id: '',
      name: '',
      username: '',
      bio: '',
      avatarUrl: '',
      followers: 0,
      following: 0,
      posts: 0,
    );
  }
}

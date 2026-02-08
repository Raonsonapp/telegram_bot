class UserModel {
  final int id;
  final String username;
  final String avatar;
  final String bio;
  int followers;
  int following;
  bool isVerified;
  bool isFollowing;

  UserModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.bio,
    this.followers = 0,
    this.following = 0,
    this.isVerified = false,
    this.isFollowing = false,
  });
}

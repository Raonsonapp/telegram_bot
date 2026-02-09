class PostModel {
  PostModel({
    required this.id,
    required this.username,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    this.avatarUrl = '',
    this.location,
    this.timeAgo = '2h',
    this.liked = false,
    this.saved = false,
  });

  final String id;
  final String username;
  final String caption;
  final String imageUrl;
  final String avatarUrl;
  final String? location;
  final String timeAgo;
  int likes;
  bool liked;
  bool saved;

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      caption: map['caption']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString() ?? '',
      location: map['location']?.toString(),
      timeAgo: map['timeAgo']?.toString() ?? '2h',
      likes: map['likes'] is int ? map['likes'] as int : 0,
    );
  }
}

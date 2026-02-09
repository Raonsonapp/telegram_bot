class ReelModel {
  ReelModel({
    required this.id,
    required this.username,
    required this.caption,
    required this.videoUrl,
    required this.likes,
    required this.comments,
  });

  final String id;
  final String username;
  final String caption;
  final String videoUrl;
  final int likes;
  final int comments;

  factory ReelModel.fromMap(Map<String, dynamic> map) {
    return ReelModel(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      caption: map['caption']?.toString() ?? '',
      videoUrl: map['videoUrl']?.toString() ?? '',
      likes: map['likes'] is int ? map['likes'] as int : 0,
      comments: map['comments'] is int ? map['comments'] as int : 0,
    );
  }
}

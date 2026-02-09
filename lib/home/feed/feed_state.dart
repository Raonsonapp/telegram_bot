import '../../models/post_model.dart';

class FeedState {
  FeedState({required this.posts, this.loading = false, this.error});

  final List<PostModel> posts;
  final bool loading;
  final String? error;

  FeedState copyWith({
    List<PostModel>? posts,
    bool? loading,
    String? error,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

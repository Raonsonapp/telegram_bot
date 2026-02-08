class PostActionsService {
  // ===== MOCK STATE =====
  static final Set<int> _likedPosts = {};

  static Future<bool> isLiked(int postId) async {
    return _likedPosts.contains(postId);
  }

  static Future<int> like(int postId, int currentLikes) async {
    _likedPosts.add(postId);
    return currentLikes + 1;
  }

  static Future<int> unlike(int postId, int currentLikes) async {
    _likedPosts.remove(postId);
    return currentLikes > 0 ? currentLikes - 1 : 0;
  }
}

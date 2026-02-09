/// lib/core/api.dart
/// =====================================================
/// RAONSON API – FULL & FINAL (v5)
/// Contract between Flutter <-> Backend
/// =====================================================

class Api {
  Api._(); // no instance

  // =====================================================
  // BASE
  // =====================================================

  /// CHANGE ONLY THIS IF SERVER MOVES
  static const String baseUrl = 'https://raonson-me.onrender.com';

  static const String api = '$baseUrl/api';

  // =====================================================
  // AUTH
  // =====================================================

  static const String auth = '$api/auth';

  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String logout = '$auth/logout';
  static const String refresh = '$auth/refresh';

  // =====================================================
  // USER / PROFILE
  // =====================================================

  static const String users = '$api/users';

  /// GET /users/me
  static const String me = '$users/me';

  /// GET /users/{username}
  static String userProfile(String username) =>
      '$users/$username';

  /// PUT /users/me
  static const String editProfile = '$users/me';

  // =====================================================
  // FOLLOW SYSTEM
  // =====================================================

  static const String follow = '$api/follow';

  /// POST /follow/{username}
  static String followUser(String username) =>
      '$follow/$username';

  /// DELETE /follow/{username}
  static String unfollowUser(String username) =>
      '$follow/$username';

  /// GET /follow/{username}/followers
  static String followers(String username) =>
      '$follow/$username/followers';

  /// GET /follow/{username}/following
  static String following(String username) =>
      '$follow/$username/following';

  /// GET /follow/{username}/is-following
  static String isFollowing(String username) =>
      '$follow/$username/is-following';

  // =====================================================
  // POSTS
  // =====================================================

  static const String posts = '$api/posts';

  /// POST /posts
  static const String createPost = posts;

  /// GET /posts/feed
  static const String feedPosts = '$posts/feed';

  /// GET /posts/user/{username}
  static String userPosts(String username) =>
      '$posts/user/$username';

  /// DELETE /posts/{postId}
  static String deletePost(int postId) =>
      '$posts/$postId';

  // =====================================================
  // POST ACTIONS (LIKE / SAVE)
  // =====================================================

  /// POST /posts/{id}/like
  static String likePost(int postId) =>
      '$posts/$postId/like';

  /// POST /posts/{id}/unlike
  static String unlikePost(int postId) =>
      '$posts/$postId/unlike';

  /// POST /posts/{id}/save
  static String savePost(int postId) =>
      '$posts/$postId/save';

  /// POST /posts/{id}/unsave
  static String unsavePost(int postId) =>
      '$posts/$postId/unsave';

  /// GET /posts/saved
  static const String savedPosts = '$posts/saved';

  // =====================================================
  // COMMENTS
  // =====================================================

  static const String comments = '$api/comments';

  /// GET /comments/{postId}
  static String getComments(int postId) =>
      '$comments/$postId';

  /// POST /comments/{postId}
  static String addComment(int postId) =>
      '$comments/$postId';

  // =====================================================
  // STORIES
  // =====================================================

  static const String stories = '$api/stories';

  /// POST /stories
  static const String createStory = stories;

  /// GET /stories/feed
  static const String storiesFeed = '$stories/feed';

  /// POST /stories/{id}/view
  static String viewStory(int storyId) =>
      '$stories/$storyId/view';

  // =====================================================
  // REELS
  // =====================================================

  static const String reels = '$api/reels';

  /// POST /reels
  static const String createReel = reels;

  /// GET /reels/feed
  static const String reelsFeed = '$reels/feed';

  /// POST /reels/{id}/like
  static String likeReel(int reelId) =>
      '$reels/$reelId/like';

  /// POST /reels/{id}/unlike
  static String unlikeReel(int reelId) =>
      '$reels/$reelId/unlike';

  /// POST /reels/{id}/save
  static String saveReel(int reelId) =>
      '$reels/$reelId/save';

  /// POST /reels/{id}/unsave
  static String unsaveReel(int reelId) =>
      '$reels/$reelId/unsave';

  /// GET /reels/saved
  static const String savedReels = '$reels/saved';

  // =====================================================
  // CHAT
  // =====================================================

  static const String chats = '$api/chats';

  /// GET /chats
  static const String chatList = chats;

  /// GET /chats/{chatId}
  static String chatMessages(int chatId) =>
      '$chats/$chatId';

  /// POST /chats/{chatId}/send
  static String sendMessage(int chatId) =>
      '$chats/$chatId/send';

  // =====================================================
  // SEARCH
  // =====================================================

  /// GET /search?q=keyword
  static const String search = '$api/search';
}

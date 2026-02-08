// lib/core/api.dart

class Api {
  /// ===============================
  /// BASE CONFIG
  /// ===============================

  // TODO: ҳангоми deployment иваз мешавад
  static const String baseUrl = 'https://api.raonson.com';

  /// ===============================
  /// AUTH
  /// ===============================

  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh';

  /// ===============================
  /// USER / PROFILE
  /// ===============================

  static const String me = '$baseUrl/users/me';
  static String userById(int userId) => '$baseUrl/users/$userId';

  static String followUser(int userId) => '$baseUrl/users/$userId/follow';
  static String unfollowUser(int userId) => '$baseUrl/users/$userId/unfollow';

  static String followers(int userId) => '$baseUrl/users/$userId/followers';
  static String following(int userId) => '$baseUrl/users/$userId/following';

  /// ===============================
  /// POSTS (FEED)
  /// ===============================

  static const String feed = '$baseUrl/posts/feed';
  static const String createPost = '$baseUrl/posts';

  static String postById(int postId) => '$baseUrl/posts/$postId';
  static String deletePost(int postId) => '$baseUrl/posts/$postId';

  static String likePost(int postId) => '$baseUrl/posts/$postId/like';
  static String unlikePost(int postId) => '$baseUrl/posts/$postId/unlike';

  static String postComments(int postId) =>
      '$baseUrl/posts/$postId/comments';

  /// ===============================
  /// STORIES
  /// ===============================

  static const String stories = '$baseUrl/stories';
  static String markStoryViewed(int storyId) =>
      '$baseUrl/stories/$storyId/view';

  /// ===============================
  /// REELS
  /// ===============================

  static const String reels = '$baseUrl/reels';
  static String reelById(int reelId) => '$baseUrl/reels/$reelId';

  static String likeReel(int reelId) => '$baseUrl/reels/$reelId/like';
  static String unlikeReel(int reelId) => '$baseUrl/reels/$reelId/unlike';

  /// ===============================
  /// SEARCH
  /// ===============================

  static String search(String query) =>
      '$baseUrl/search?q=$query';

  /// ===============================
  /// CHAT
  /// ===============================

  static const String chats = '$baseUrl/chats';
  static String messages(int chatId) =>
      '$baseUrl/chats/$chatId/messages';
}

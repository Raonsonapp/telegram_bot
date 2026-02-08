/// lib/core/api.dart
class Api {
  static const String baseUrl = 'https://raonson-me.onrender.com';

  // ===== AUTH =====
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh';

  // ===== USER =====
  static const String me = '$baseUrl/users/me';
  static const String userProfile = '$baseUrl/users';
  static const String editProfile = '$baseUrl/users/edit';

  // ===== FOLLOW =====
  static const String follow = '$baseUrl/follow';

  /// ✅ ALIAS (барои service-ҳо)
  static const String followEndpoint = follow;

  // ===== POSTS =====
  static const String createPost = '$baseUrl/posts/create';
  static const String feedPosts = '$baseUrl/posts/feed';
  static const String userPosts = '$baseUrl/posts/user';
  static const String deletePost = '$baseUrl/posts/delete';

  static const String likePost = '$baseUrl/posts/like';
  static const String unlikePost = '$baseUrl/posts/unlike';
  static const String savePost = '$baseUrl/posts/save';
  static const String unsavePost = '$baseUrl/posts/unsave';

  // ===== COMMENTS =====
  static const String comments = '$baseUrl/comments';
  static const String addComment = '$baseUrl/comments/add';

  // ===== STORIES =====
  static const String createStory = '$baseUrl/stories/create';
  static const String getStories = '$baseUrl/stories/feed';
  static const String viewStory = '$baseUrl/stories/view';

  // ===== REELS =====
  static const String createReel = '$baseUrl/reels/create';
  static const String getReels = '$baseUrl/reels/feed';

  /// ✅ ALIAS (барои reel_service)
  static const String reelsEndpoint = '$baseUrl/reels';

  // ===== CHAT =====
  static const String chats = '$baseUrl/chats';
  static const String messages = '$baseUrl/messages';
  static const String sendMessage = '$baseUrl/messages/send';

  // ===== SEARCH =====
  static const String search = '$baseUrl/search';
}

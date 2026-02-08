/// lib/core/api.dart
/// Central API configuration for Raonson App
/// Version: v5 (Full Social Network)

class Api {
  // ================= BASE =================
  /// Main backend URL
  /// Example: https://raonson-me.onrender.com
  static const String baseUrl = 'https://raonson-me.onrender.com';

  // ================= AUTH =================
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh';

  // ================= USER =================
  static const String me = '$baseUrl/users/me';
  static const String userProfile = '$baseUrl/users'; // /{username}
  static const String editProfile = '$baseUrl/users/edit';

  // ================= FOLLOW =================
  static const String follow = '$baseUrl/follow';
  static const String unfollow = '$baseUrl/unfollow';
  static const String followers = '$baseUrl/followers'; // /{username}
  static const String following = '$baseUrl/following'; // /{username}

  // ================= POSTS =================
  static const String createPost = '$baseUrl/posts/create';
  static const String feedPosts = '$baseUrl/posts/feed';
  static const String userPosts = '$baseUrl/posts/user'; // /{username}
  static const String deletePost = '$baseUrl/posts/delete'; // /{postId}

  // ================= POST ACTIONS =================
  static const String likePost = '$baseUrl/posts/like';     // /{postId}
  static const String unlikePost = '$baseUrl/posts/unlike'; // /{postId}
  static const String savePost = '$baseUrl/posts/save';     // /{postId}
  static const String unsavePost = '$baseUrl/posts/unsave'; // /{postId}

  // ================= COMMENTS =================
  static const String comments = '$baseUrl/comments';        // /{postId}
  static const String addComment = '$baseUrl/comments/add';  // /{postId}

  // ================= STORIES =================
  static const String createStory = '$baseUrl/stories/create';
  static const String getStories = '$baseUrl/stories/feed';
  static const String viewStory = '$baseUrl/stories/view'; // /{storyId}

  // ================= REELS =================
  static const String createReel = '$baseUrl/reels/create';
  static const String getReels = '$baseUrl/reels/feed';

  // ================= CHAT =================
  static const String chats = '$baseUrl/chats';
  static const String messages = '$baseUrl/messages'; // /{chatId}
  static const String sendMessage = '$baseUrl/messages/send';

  // ================= SEARCH =================
  static const String search = '$baseUrl/search'; // ?q=keyword
}

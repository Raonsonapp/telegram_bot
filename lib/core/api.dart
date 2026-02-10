/// lib/core/api.dart
/// =====================================================
/// API ENDPOINTS – Raonson Social App
/// Centralized REST API routes
/// Compatible with FastAPI backend (Render)
/// Base URL: https://raonson-me.onrender.com
/// =====================================================

class Api {
  // =====================================================
  // BASE
  // =====================================================
  static const String baseUrl = 'https://raonson-me.onrender.com';

  // =====================================================
  // AUTH
  // =====================================================
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';
  static const String verifyEmail = '/auth/verify-email';

  // =====================================================
  // USER / PROFILE
  // =====================================================
  static const String myProfile = '/users/me';
  static String userProfile(String username) => '/users/$username';

  static const String updateProfile = '/users/update';
  static const String uploadAvatar = '/users/avatar';

  static String blockUser(int userId) => '/users/$userId/block';
  static String unblockUser(int userId) => '/users/$userId/unblock';
  static String reportUser(int userId) => '/users/$userId/report';

  // =====================================================
  // FOLLOW SYSTEM
  // =====================================================
  static String follow(int userId) => '/follow/$userId';
  static String unfollow(int userId) => '/unfollow/$userId';

  static String followers(String username) =>
      '/users/$username/followers';
  static String following(String username) =>
      '/users/$username/following';

  static const String followRequests = '/follow/requests';
  static String acceptFollow(int requestId) =>
      '/follow/requests/$requestId/accept';
  static String rejectFollow(int requestId) =>
      '/follow/requests/$requestId/reject';

  // =====================================================
  // POSTS
  // =====================================================
  static const String createPost = '/posts';
  static const String feedPosts = '/posts/feed';

  static String userPosts(String username) =>
      '/posts/user/$username';

  static String postById(int postId) => '/posts/$postId';
  static String deletePost(int postId) => '/posts/$postId/delete';
  static String editCaption(int postId) => '/posts/$postId/edit';

  static String likePost(int postId) => '/posts/$postId/like';
  static String unlikePost(int postId) => '/posts/$postId/unlike';

  static String savePost(int postId) => '/posts/$postId/save';
  static String unsavePost(int postId) => '/posts/$postId/unsave';

  static String reportPost(int postId) => '/posts/$postId/report';

  // =====================================================
  // COMMENTS
  // =====================================================
  static String getComments(int postId) =>
      '/posts/$postId/comments';

  static String addComment(int postId) =>
      '/posts/$postId/comments';

  static String deleteComment(int commentId) =>
      '/comments/$commentId/delete';

  // =====================================================
  // STORIES
  // =====================================================
  static const String getStories = '/stories';
  static const String createStory = '/stories';

  static String viewStory(int storyId) =>
      '/stories/$storyId/view';

  static String storyViewers(int storyId) =>
      '/stories/$storyId/viewers';

  static String muteStory(int userId) =>
      '/stories/mute/$userId';

  static const String storyHighlights = '/stories/highlights';

  // =====================================================
  // REELS
  // =====================================================
  static const String getReels = '/reels';
  static const String createReel = '/reels';

  static String reelById(int reelId) => '/reels/$reelId';

  static String likeReel(int reelId) => '/reels/$reelId/like';
  static String unlikeReel(int reelId) => '/reels/$reelId/unlike';

  static String saveReel(int reelId) => '/reels/$reelId/save';
  static String unsaveReel(int reelId) => '/reels/$reelId/unsave';

  static String reelComments(int reelId) =>
      '/reels/$reelId/comments';

  // =====================================================
  // SEARCH & DISCOVER
  // =====================================================
  static const String search = '/search';
  static String searchHashtag(String tag) => '/search/hashtag/$tag';
  static const String trending = '/search/trending';
  static const String categories = '/search/categories';

  // =====================================================
  // CHAT / MESSAGING
  // =====================================================
  static const String chats = '/chats';

  static String messages(String chatId) =>
      '/chats/$chatId/messages';

  static String sendMessage(String chatId) =>
      '/chats/$chatId/send';

  static String markChatRead(String chatId) =>
      '/chats/$chatId/read';

  static String deleteMessage(int messageId) =>
      '/messages/$messageId/delete';

  static String blockChatUser(int userId) =>
      '/chats/block/$userId';

  // =====================================================
  // NOTIFICATIONS
  // =====================================================
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount =
      '/notifications/unread-count';

  static String markNotificationRead(int id) =>
      '/notifications/$id/read';

  static const String markAllNotificationsRead =
      '/notifications/read-all';

  static String deleteNotification(int id) =>
      '/notifications/$id';

  static const String clearNotifications =
      '/notifications/clear';

  // =====================================================
  // SETTINGS
  // =====================================================
  static const String settings = '/settings';
  static const String privacySettings = '/settings/privacy';
  static const String notificationSettings =
      '/settings/notifications';
  static const String securitySettings = '/settings/security';

  // =====================================================
  // UTIL
  // =====================================================
  static Uri uri(String path) {
    return Uri.parse('$baseUrl$path');
  }
}

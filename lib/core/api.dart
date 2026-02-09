/// =====================================================
/// RAONSON API CONFIG – CORE
/// Central place for all backend endpoints
/// =====================================================

class Api {
  Api._();

  // ================= BASE =================
  static const String baseUrl = 'https://api.raonson.com';
  static const String api = '$baseUrl/api';

  // ================= AUTH =================
  static const String auth = '$api/auth';

  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String logout = '$auth/logout';
  static const String refresh = '$auth/refresh';

  static const String forgotPassword = '$auth/forgot-password';
  static const String changePassword = '$auth/change-password';
  static const String verifyEmail = '$auth/verify-email';
  static const String verifyPhone = '$auth/verify-phone';

  // ================= USERS / PROFILE =================
  static const String users = '$api/users';

  static const String me = '$users/me';

  static String userProfile(String username) =>
      '$users/$username';

  static const String editProfile = '$users/edit';
  static const String uploadAvatar = '$users/avatar';

  static String blockUser(int userId) =>
      '$users/$userId/block';

  static String unblockUser(int userId) =>
      '$users/$userId/unblock';

  static String reportUser(int userId) =>
      '$users/$userId/report';

  // ================= FOLLOW SYSTEM =================
  static const String follow = '$api/follow';

  static String followUser(String username) =>
      '$follow/$username';

  static String unfollowUser(String username) =>
      '$follow/$username/unfollow';

  static String followers(String username) =>
      '$follow/$username/followers';

  static String following(String username) =>
      '$follow/$username/following';

  static String followRequests(String username) =>
      '$follow/$username/requests';

  static String removeFollower(String username) =>
      '$follow/$username/remove';

  // ================= POSTS =================
  static const String posts = '$api/posts';

  static const String createPost = posts;
  static const String feedPosts = '$posts/feed';

  static String userPosts(String username) =>
      '$posts/user/$username';

  static String postById(int postId) =>
      '$posts/$postId';

  static String deletePost(int postId) =>
      '$posts/$postId';

  static String editPost(int postId) =>
      '$posts/$postId/edit';

  // ===== POST ACTIONS =====
  static String likePost(int postId) =>
      '$posts/$postId/like';

  static String unlikePost(int postId) =>
      '$posts/$postId/unlike';

  static String savePost(int postId) =>
      '$posts/$postId/save';

  static String unsavePost(int postId) =>
      '$posts/$postId/unsave';

  static String sharePost(int postId) =>
      '$posts/$postId/share';

  // ================= COMMENTS =================
  static const String comments = '$api/comments';

  static String getComments(int postId) =>
      '$comments/post/$postId';

  static String addComment(int postId) =>
      '$comments/post/$postId';

  static String deleteComment(int commentId) =>
      '$comments/$commentId';

  static String reportComment(int commentId) =>
      '$comments/$commentId/report';

  // ================= STORIES =================
  static const String stories = '$api/stories';

  static const String createStory = stories;
  static const String storiesFeed = '$stories/feed';

  static String viewStory(int storyId) =>
      '$stories/$storyId/view';

  static String storyViewers(int storyId) =>
      '$stories/$storyId/viewers';

  static String muteStory(String username) =>
      '$stories/mute/$username';

  static const String highlights = '$stories/highlights';

  // ================= REELS =================
  static const String reels = '$api/reels';

  static const String reelsFeed = '$reels/feed';
  static const String createReel = reels;

  static String reelById(int reelId) =>
      '$reels/$reelId';

  static String likeReel(int reelId) =>
      '$reels/$reelId/like';

  static String unlikeReel(int reelId) =>
      '$reels/$reelId/unlike';

  static String saveReel(int reelId) =>
      '$reels/$reelId/save';

  static String unsaveReel(int reelId) =>
      '$reels/$reelId/unsave';

  // ================= SEARCH =================
  static const String search = '$api/search';

  static String searchUsers(String q) =>
      '$search/users?q=$q';

  static String searchPosts(String q) =>
      '$search/posts?q=$q';

  static String searchReels(String q) =>
      '$search/reels?q=$q';

  static String searchHashtag(String tag) =>
      '$search/hashtag/$tag';

  static const String trending = '$search/trending';

  // ================= CHAT =================
  static const String chats = '$api/chats';

  static String messages(String chatId) =>
      '$chats/$chatId/messages';

  static String sendMessage(String chatId) =>
      '$chats/$chatId/send';

  static String deleteMessage(String messageId) =>
      '$chats/message/$messageId';

  static String typing(String chatId) =>
      '$chats/$chatId/typing';

  // ================= NOTIFICATIONS =================
  static const String notifications = '$api/notifications';

  static const String notificationsUnreadCount =
      '$notifications/unread-count';

  static String markNotificationRead(int id) =>
      '$notifications/$id/read';

  static const String markAllNotificationsRead =
      '$notifications/read-all';

  static String deleteNotification(int id) =>
      '$notifications/$id';

  static const String clearNotifications =
      '$notifications/clear';
}

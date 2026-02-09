/// lib/core/api.dart
/// =====================================================
/// RAONSON API – FULL & FINAL (v5) ✅ FIXED
/// Single source of truth for all endpoints
/// =====================================================

class Api {
  Api._();

  // =====================================================
  // BASE
  // =====================================================

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
  // USERS / PROFILE
  // =====================================================

  static const String users = '$api/users';

  static const String me = '$users/me';

  static String userProfile(String username) =>
      '$users/$username';

  static const String editProfile = '$users/me';

  // =====================================================
  // FOLLOW SYSTEM
  // =====================================================

  static const String follow = '$api/follow';
  static const String unfollow = '$api/unfollow';

  static String followUser(String username) =>
      '$follow/$username';

  static String unfollowUser(String username) =>
      '$unfollow/$username';

  static String followers(String username) =>
      '$follow/$username/followers';

  static String following(String username) =>
      '$follow/$username/following';

  static String isFollowing(String username) =>
      '$follow/$username/is-following';

  static String followCounts(String username) =>
      '$follow/counts/$username';

  // =====================================================
  // POSTS
  // =====================================================

  static const String posts = '$api/posts';

  static const String createPost = posts;
  static const String feedPosts = '$posts/feed';

  static String userPosts(String username) =>
      '$posts/user/$username';

  static String deletePost(int postId) =>
      '$posts/$postId';

  // ---------- POST ACTIONS ----------

  static String likePost(int postId) =>
      '$posts/$postId/like';

  static String unlikePost(int postId) =>
      '$posts/$postId/unlike';

  static String savePost(int postId) =>
      '$posts/$postId/save';

  static String unsavePost(int postId) =>
      '$posts/$postId/unsave';

  static const String savedPosts = '$posts/saved';

  // =====================================================
  // COMMENTS
  // =====================================================

  static const String comments = '$api/comments';

  static String getComments(int postId) =>
      '$comments/$postId';

  static String addComment(int postId) =>
      '$comments/$postId';

  static String likeComment(int commentId) =>
      '$comments/$commentId/like';

  static String unlikeComment(int commentId) =>
      '$comments/$commentId/unlike';

  // =====================================================
  // STORIES
  // =====================================================

  static const String stories = '$api/stories';

  static const String createStory = stories;
  static const String getStories = '$stories/feed';

  static String viewStory(int storyId) =>
      '$stories/$storyId/view';

  // =====================================================
  // REELS
  // =====================================================

  static const String reels = '$api/reels';

  static const String createReel = reels;
  static const String getReels = '$reels/feed';

  static String likeReel(int reelId) =>
      '$reels/$reelId/like';

  static String unlikeReel(int reelId) =>
      '$reels/$reelId/unlike';

  static String saveReel(int reelId) =>
      '$reels/$reelId/save';

  static String unsaveReel(int reelId) =>
      '$reels/$reelId/unsave';

  static const String savedReels = '$reels/saved';

  // =====================================================
  // CHAT / MESSAGES
  // =====================================================

  static const String chats = '$api/chats';

  static String chatMessages(int chatId) =>
      '$chats/$chatId';

  static String sendMessage(int chatId) =>
      '$chats/$chatId/send';

  static String markChatRead(int chatId) =>
      '$chats/$chatId/read';

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

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

  // =====================================================
  // SEARCH
  // =====================================================

  static const String search = '$api/search';

  static String searchUsers(String query) =>
      '$search/users?q=$query';

  static String searchPosts(String query) =>
      '$search/posts?q=$query';

  static String searchHashtags(String query) =>
      '$search/hashtags?q=$query';

  // =====================================================
  // REPORTS
  // =====================================================

  static const String reports = '$api/reports';

  static const String createReport = reports;
}

class Api {
   static const baseUrl = 'https://YOUR_SERVER_URL';
   static const chatEndpoint = '$baseUrl/chats';
   static const String notificationsEndpoint = '$baseUrl/notifications';
   static const String postsEndpoint = '$baseUrl/posts';
   static const String storiesEndpoint = '$baseUrl/stories';

  static const searchUsersEndpoint = '$baseUrl/search/users';
  static const searchPostsEndpoint = '$baseUrl/search/posts';

  // already existing:
  static const postsEndpoint = '$baseUrl/posts';
  static const searchUsersEndpoint = '$baseUrl/search/users';
  static const searchPostsEndpoint = '$baseUrl/search/posts';
  static const followEndpoint = '$baseUrl/follow';
  static const unfollowEndpoint = '$baseUrl/unfollow';
  static const profileEndpoint = '$baseUrl/profile';
  // ===== BASE =====
  static const String baseUrl = 'https://raonson-me.onrender.com';

  // ===== AUTH =====
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String refreshToken = '$baseUrl/auth/refresh';

  // ===== POSTS =====
  static const String posts = '$baseUrl/posts';
  static String postById(int id) => '$baseUrl/posts/$id';
  static String likePost(int id) => '$baseUrl/posts/$id/like';
  static String unlikePost(int id) => '$baseUrl/posts/$id/unlike';
  static String comments(int id) => '$baseUrl/posts/$id/comments';

  // ===== STORIES =====
  static const String stories = '$baseUrl/stories';
  static String viewStory(int id) => '$baseUrl/stories/$id/view';

  // ===== REELS =====
  static const String reels = '$baseUrl/reels';
  static const String reelsEndpoint = '$baseUrl/reels';

  // ===== FOLLOW =====
  static String followUser(String username) =>
      '$baseUrl/users/$username/follow';
  static String unfollowUser(String username) =>
      '$baseUrl/users/$username/unfollow';
  static String followers(String username) =>
      '$baseUrl/users/$username/followers';
  static String following(String username) =>
      '$baseUrl/users/$username/following';

  // ===== PROFILE =====
  static String profile(String username) =>
      '$baseUrl/users/$username';

  // ===== CHAT =====
  static const String chats = '$baseUrl/chats';
  static String messages(int chatId) => '$baseUrl/chats/$chatId/messages';
}

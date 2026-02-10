import 'package:flutter/material.dart';

// Auth
import '../auth/login/login_screen.dart';
import '../auth/register/register_screen.dart';
import '../auth/forgot_password/forgot_password_screen.dart';
import '../auth/change_password/change_password_screen.dart';
import '../auth/verify_email/verify_email_screen.dart';

// Home / Core tabs
import '../home/feed/feed_screen.dart';
import '../reels/reels_feed/reels_screen.dart';
import '../search/search_main/search_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_main/profile_screen.dart';

// Profile / Settings
import '../profile/edit_profile/edit_profile_screen.dart';
import '../profile/followers/followers_screen.dart';
import '../profile/following/following_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/privacy_settings.dart';
import '../settings/notification_settings.dart';
import '../settings/security_settings.dart';

// Chat
import '../chat/chat_list/chat_list_screen.dart';
import '../chat/chat_room/chat_room_screen.dart';

// Misc
import '../home/comments/comments_screen.dart';
import '../reels/reel_comments/reel_comments_screen.dart';
import '../search/hashtag/hashtag_screen.dart';

/// Centralized named routes for Raonson
/// Keep this file declarative and side-effect free.
class AppRoutes {
  // ===== Root =====
  static const String splash = '/';
  static const String home = '/home';

  // ===== Auth =====
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';
  static const String verifyEmail = '/auth/verify-email';

  // ===== Tabs =====
  static const String feed = '/tabs/feed';
  static const String reels = '/tabs/reels';
  static const String search = '/tabs/search';
  static const String notifications = '/tabs/notifications';
  static const String profile = '/tabs/profile';

  // ===== Profile =====
  static const String editProfile = '/profile/edit';
  static const String followers = '/profile/followers';
  static const String following = '/profile/following';

  // ===== Chat =====
  static const String chatList = '/chat';
  static const String chatRoom = '/chat/room';

  // ===== Content =====
  static const String comments = '/comments';
  static const String reelComments = '/reel/comments';
  static const String hashtag = '/hashtag';

  // ===== Settings =====
  static const String settings = '/settings';
  static const String privacySettings = '/settings/privacy';
  static const String notificationSettings = '/settings/notifications';
  static const String securitySettings = '/settings/security';

  /// Generate routes here to keep arguments typed and consistent.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // -------- Auth --------
      case login:
        return _page(const LoginScreen());
      case register:
        return _page(const RegisterScreen());
      case forgotPassword:
        return _page(const ForgotPasswordScreen());
      case changePassword:
        return _page(const ChangePasswordScreen());
      case verifyEmail:
        return _page(const VerifyEmailScreen());

      // -------- Tabs --------
      case feed:
        return _page(const FeedScreen());
      case reels:
        return _page(const ReelsScreen());
      case search:
        return _page(const SearchScreen());
      case notifications:
        return _page(const NotificationsScreen());
      case profile:
        return _page(const ProfileScreen());

      // -------- Profile --------
      case editProfile:
        return _page(const EditProfileScreen());
      case followers:
        return _page(const FollowersScreen());
      case following:
        return _page(const FollowingScreen());

      // -------- Chat --------
      case chatList:
        return _page(const ChatListScreen());
      case chatRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return _page(
          ChatRoomScreen(
            chatId: args['chatId'] as String,
            peerUser: args['peerUser'],
          ),
        );

      // -------- Content --------
      case comments:
        final postId = settings.arguments as int;
        return _page(CommentsScreen(postId: postId));
      case reelComments:
        final reelId = settings.arguments as int;
        return _page(ReelCommentsScreen(reelId: reelId));
      case hashtag:
        final tag = settings.arguments as String;
        return _page(HashtagScreen(hashtag: tag));

      // -------- Settings --------
      case settings:
        return _page(const SettingsScreen());
      case privacySettings:
        return _page(const PrivacySettingsScreen());
      case notificationSettings:
        return _page(const NotificationSettingsScreen());
      case securitySettings:
        return _page(const SecuritySettingsScreen());

      default:
        return _page(
          Scaffold(
            body: Center(
              child: Text(
                'Route not found: ${settings.name}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
    }
  }

  static PageRoute _page(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}

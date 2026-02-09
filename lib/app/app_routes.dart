// lib/app/app_routes.dart
import 'package:flutter/material.dart';

// ===== AUTH =====
import '../auth/login/login_screen.dart';
import '../auth/register/register_screen.dart';
import '../auth/forgot_password/forgot_password_screen.dart';
import '../auth/change_password/change_password_screen.dart';
import '../auth/verify_email/verify_email_screen.dart';

// ===== HOME / MAIN =====
import '../navigation/bottom_nav.dart';

// ===== PROFILE =====
import '../profile/profile_main/profile_screen.dart';
import '../profile/edit_profile/edit_profile_screen.dart';

// ===== CHAT =====
import '../chat/chat_room/chat_room_screen.dart';

// ===== NOTIFICATIONS =====
import '../notifications/notifications_screen.dart';

// ===== CORE =====
import '../core/session_manager.dart';

class AppRoutes {
  AppRoutes._();

  // ================= ROUTE NAMES =================
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';
  static const String verifyEmail = '/verify-email';

  static const String home = '/home';

  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  static const String chatRoom = '/chat/room';

  static const String notifications = '/notifications';

  // ================= GENERATOR =================
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      // ===== AUTH =====
      case login:
        return _page(const LoginScreen());

      case register:
        return _page(const RegisterScreen());

      case forgotPassword:
        return _page(const ForgotPasswordScreen());

      case changePassword:
        return _guarded(const ChangePasswordScreen());

      case verifyEmail:
        return _guarded(const VerifyEmailScreen());

      // ===== HOME =====
      case home:
        return _guarded(const BottomNav());

      // ===== PROFILE =====
      case profile:
        final username = settings.arguments as String?;
        return _guarded(ProfileScreen(username: username));

      case editProfile:
        return _guarded(const EditProfileScreen());

      // ===== CHAT =====
      case chatRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return _guarded(
          ChatRoomScreen(
            chatId: args['chatId'],
            user: args['user'],
          ),
        );

      // ===== NOTIFICATIONS =====
      case notifications:
        return _guarded(const NotificationsScreen());

      // ===== FALLBACK =====
      default:
        return _error();
    }
  }

  // ================= HELPERS =================

  static MaterialPageRoute _page(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }

  static MaterialPageRoute _guarded(Widget child) {
    return MaterialPageRoute(
      builder: (context) {
        final session = SessionManager.of(context);

        if (!session.isLoggedIn) {
          return const LoginScreen();
        }

        return child;
      },
    );
  }

  static MaterialPageRoute _error() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text(
            '404\nPage not found',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

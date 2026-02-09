// lib/navigation/app_router.dart
// =====================================================
// APP ROUTER – FINAL v5
// Build-safe, async-safe, production-ready
// =====================================================

import 'package:flutter/material.dart';

import '../core/session.dart';

// Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

// Main
import 'bottom_nav.dart';

// Profile
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/settings_screen.dart';

// Chat
import '../screens/chat/chat_room_screen.dart';

class AppRouter {
  // ================= ROUTE NAMES =================
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';

  static const String home = '/home';

  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  static const String chatRoom = '/chat/room';

  // ================= GENERATE ROUTE =================
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case root:
      case home:
        return _guard(const BottomNav());

      case login:
        return _page(
          LoginScreen(
            onLoginSuccess: () {},
            onRegisterTap: () {},
          ),
        );

      case register:
        return _page(const RegisterScreen());

      case editProfile:
        return _guard(const EditProfileScreen());

      case settings:
        return _guard(const SettingsScreen());

      case chatRoom:
        final args = settings.arguments;
        if (args is! Map<String, dynamic>) {
          return _error();
        }

        final chatId = args['chatId'];
        final username = args['username'];

        if (chatId == null || username == null) {
          return _error();
        }

        return _guard(
          ChatRoomScreen(
            chatId: chatId.toString(),
            username: username.toString(),
          ),
        );

      default:
        return _error();
    }
  }

  // ================= HELPERS =================

  static MaterialPageRoute _page(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }

  /// AUTH GUARD (SYNC, SAFE)
  static MaterialPageRoute _guard(Widget child) {
    return MaterialPageRoute(
      builder: (context) {
        final loggedIn = Session.isLoggedInSync();

        if (!loggedIn) {
          return LoginScreen(
            onLoginSuccess: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(home, (_) => false);
            },
            onRegisterTap: () {
              Navigator.of(context).pushNamed(register);
            },
          );
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
            '404\nRoute not found',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

// lib/navigation/app_router.dart

import 'package:flutter/material.dart';

import '../core/session.dart';

// Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

// Main
import '../navigation/bottom_nav.dart';

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
        return _guarded(const BottomNav());

      case login:
        return _page(
          LoginScreen(
            onLoginSuccess: () {},
            onRegisterTap: () {},
          ),
        );

      case register:
        return _page(const RegisterScreen());

      case home:
        return _guarded(const BottomNav());

      case editProfile:
        return _guarded(const EditProfileScreen());

      case settings:
        return _guarded(const SettingsScreen());

      case chatRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return _guarded(
          ChatRoomScreen(
            chatId: args['chatId'],
            username: args['username'],
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

  static MaterialPageRoute _guarded(Widget child) {
    return MaterialPageRoute(
      builder: (_) => FutureBuilder<bool>(
        future: Session.isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.data!) {
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
      ),
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

import 'package:flutter/material.dart';

import '../auth/auth_routes.dart';
import '../auth/login/login_screen.dart';
import '../auth/register/register_screen.dart';
import '../auth/forgot_password/forgot_password_screen.dart';
import '../auth/change_password/change_password_screen.dart';
import '../auth/verify_email/verify_email_screen.dart';
import '../home/feed/feed_screen.dart';
import '../navigation/bottom_nav.dart';
import '../settings/settings_screen.dart';
import '../app/app_routes.dart';
import '../app/app_theme.dart';

class RaonsonApp extends StatelessWidget {
  const RaonsonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raonson',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.root,
      routes: {
        AppRoutes.root: (_) => const BottomNavShell(),
        AppRoutes.feed: (_) => const FeedScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AuthRoutes.login: (_) => const LoginScreen(),
        AuthRoutes.register: (_) => const RegisterScreen(),
        AuthRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AuthRoutes.changePassword: (_) => const ChangePasswordScreen(),
        AuthRoutes.verifyEmail: (_) => const VerifyEmailScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const BottomNavShell(),
      ),
    );
  }
}

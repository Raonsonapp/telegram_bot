// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import 'app_theme.dart';
import '../core/session_manager.dart';

class RaonsonApp extends StatelessWidget {
  const RaonsonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionManager>(
      builder: (context, session, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Raonson',

          // ===== THEME =====
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,

          // ===== ROUTING =====
          initialRoute:
              session.isLoggedIn ? AppRoutes.home : AppRoutes.login,
          onGenerateRoute: AppRoutes.generate,

          // ===== GLOBAL NAVIGATION SAFE =====
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}

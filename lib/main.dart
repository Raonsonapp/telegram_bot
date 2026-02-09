/// lib/main.dart
/// Raonson v5 — Full Social Network App
/// Single entry point, fully wired to all layers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/session.dart';
import 'core/socket_service.dart';

import 'navigation/app_router.dart';
import 'navigation/bottom_nav.dart';

import 'screens/auth/login_screen.dart';

import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation (Instagram-like)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Init local session (token, user, flags)
  await Session.init();

  // Init socket (safe even if server offline)
  await SocketService.init();

  runApp(const RaonsonApp());
}

class RaonsonApp extends StatefulWidget {
  const RaonsonApp({super.key});

  @override
  State<RaonsonApp> createState() => _RaonsonAppState();
}

class _RaonsonAppState extends State<RaonsonApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SocketService.dispose();
    super.dispose();
  }

  /// Handle app lifecycle (background / foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SocketService.reconnect();
    } else if (state == AppLifecycleState.paused) {
      SocketService.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raonson',
      debugShowCheckedModeBanner: false,

      // THEMES
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ROUTING
      onGenerateRoute: AppRouter.generate,
      home: const _Root(),

      // GLOBAL ERROR UI (failsafe)
      builder: (context, child) {
        ErrorWidget.builder = (details) {
          return Scaffold(
            body: Center(
              child: Text(
                'Raonson error:\n${details.exception}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        };
        return child!;
      },
    );
  }
}

///
/// ROOT DECIDER
/// - logged in  → BottomNav (Home / Reels / Search / Chat / Profile)
/// - not logged → Login
///
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _resolveAuth();
  }

  Future<void> _resolveAuth() async {
    try {
      final ok = await Session.isLoggedIn();
      if (!mounted) return;

      setState(() {
        _loggedIn = ok;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loggedIn = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loggedIn) {
      return const BottomNav();
    }

    return LoginScreen(
      onLoginSuccess: () async {
        await _resolveAuth();
      },
    );
  }
}

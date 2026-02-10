import 'package:flutter/material.dart';

import '../core/session_manager.dart';
import '../navigation/bottom_nav.dart';
import 'app_routes.dart';
import 'app_theme.dart';
import 'app_config.dart';

/// =====================================================
/// RaonsonApp
/// -----------------------------------------------------
/// Root widget of the application
/// - Initializes theme
/// - Handles auth / unauth state
/// - Connects navigation & routes
/// =====================================================
class RaonsonApp extends StatefulWidget {
  const RaonsonApp({super.key});

  @override
  State<RaonsonApp> createState() => _RaonsonAppState();
}

class _RaonsonAppState extends State<RaonsonApp> {
  bool _initialized = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// --------------------------------------------------
  /// App bootstrap
  /// - Load config
  /// - Restore session
  /// --------------------------------------------------
  Future<void> _bootstrap() async {
    await AppConfig.init();

    final hasSession = await SessionManager.hasValidSession();

    if (mounted) {
      setState(() {
        _isAuthenticated = hasSession;
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const _SplashLoader();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raonson',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routes: AppRoutes.routes,
      initialRoute:
          _isAuthenticated ? AppRoutes.home : AppRoutes.login,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}

/// =====================================================
/// Splash Loader
/// -----------------------------------------------------
/// Shown while app initializes
/// =====================================================
class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _Logo(),
              SizedBox(height: 24),
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =====================================================
/// App Logo
/// -----------------------------------------------------
/// Uses Raonson branding (NOT Instagram)
/// =====================================================
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(
          Icons.auto_awesome,
          size: 64,
          color: Colors.white,
        ),
        SizedBox(height: 12),
        Text(
          'Raonson',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

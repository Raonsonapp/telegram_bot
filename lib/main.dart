import 'package:flutter/material.dart';

import 'core/session.dart';
import 'navigation/bottom_nav.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.init();
  runApp(const RaonsonApp());
}

class RaonsonApp extends StatelessWidget {
  const RaonsonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raonson',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const _Root(),
    );
  }
}

///
/// ROOT — қарор мекунад:
/// 1) Агар login шуда бошад → Home (BottomNav)
/// 2) Агар не → Login
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
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final ok = await Session.isLoggedIn();
    setState(() {
      _loggedIn = ok;
      _loading = false;
    });
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
      onRegisterTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
      },
      onLoginSuccess: () {
        setState(() => _loggedIn = true);
      },
    );
  }
}

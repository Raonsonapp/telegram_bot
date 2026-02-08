import 'package:flutter/material.dart';

import 'core/session.dart';
import 'navigation/bottom_nav.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RaonsonApp());
}

class RaonsonApp extends StatelessWidget {
  const RaonsonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raonson',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const _AuthGate(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F1424),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
      ),
      fontFamily: 'Roboto',
    );
  }
}

// ================= AUTH GATE =================
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
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

    return _loggedIn ? const BottomNav() : const LoginScreen();
  }
}

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/session_manager.dart';
import 'core/network_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize session & network
  final sessionManager = SessionManager();
  await sessionManager.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionManager>.value(
          value: sessionManager,
        ),
        ChangeNotifierProvider(
          create: (_) => NetworkChecker(),
        ),
      ],
      child: const RaonsonApp(),
    ),
  );
}

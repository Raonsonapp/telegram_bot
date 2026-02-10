import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/session_manager.dart';
import 'core/token_storage.dart';
import 'core/network_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================
  // INIT CORE SERVICES
  // ============================
  await TokenStorage.init();
  await SessionManager.init();
  await NetworkChecker.init();

  // ============================
  // GLOBAL ERROR HANDLER
  // ============================
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔥 Flutter Error: ${details.exception}');
  };

  runApp(const RaonsonAppRoot());
}

///
/// ROOT WIDGET
///
class RaonsonAppRoot extends StatelessWidget {
  const RaonsonAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const RaonsonApp();
  }
}

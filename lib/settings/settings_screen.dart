import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notification_settings.dart';
import 'privacy_settings.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsController(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            PrivacySettings(),
            NotificationSettings(),
          ],
        ),
      ),
    );
  }
}

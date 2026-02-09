import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings_controller.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, controller, _) {
        return SwitchListTile(
          title: const Text('Push notifications'),
          value: controller.notificationsEnabled,
          onChanged: controller.toggleNotifications,
        );
      },
    );
  }
}

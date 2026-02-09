import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings_controller.dart';

class PrivacySettings extends StatelessWidget {
  const PrivacySettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, controller, _) {
        return SwitchListTile(
          title: const Text('Private account'),
          value: controller.privateAccount,
          onChanged: controller.togglePrivate,
        );
      },
    );
  }
}

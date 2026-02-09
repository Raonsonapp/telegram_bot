import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifications_controller.dart';
import 'notifications_repository.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsController(NotificationsRepository()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: Consumer<NotificationsController>(
          builder: (context, controller, _) {
            return ListView(
              children: controller.items
                  .map(
                    (item) => ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.description),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

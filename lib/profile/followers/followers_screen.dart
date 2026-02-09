import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'followers_controller.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FollowersController(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Followers')),
        body: Consumer<FollowersController>(
          builder: (context, controller, _) {
            return ListView(
              children: controller.followers
                  .map((name) => ListTile(title: Text(name)))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'following_controller.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FollowingController(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Following')),
        body: Consumer<FollowingController>(
          builder: (context, controller, _) {
            return ListView(
              children: controller.following
                  .map((name) => ListTile(title: Text(name)))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

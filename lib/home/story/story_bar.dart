import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/avatar_widget.dart';
import 'story_controller.dart';

class StoryBar extends StatelessWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryController(),
      child: Consumer<StoryController>(
        builder: (context, controller, _) {
          return SizedBox(
            height: 110,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final story = controller.stories[index];
                return Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF38BDF8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: AvatarWidget(imageUrl: story.imageUrl, size: 58),
                        ),
                        if (story.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'LIVE',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      story.username,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: controller.stories.length,
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/story.dart';
import '../../theme/colors.dart';
import '../../widgets/avatar.dart';

class StoryBar extends StatelessWidget {
  final List<Story> stories;

  const StoryBar({
    super.key,
    required this.stories,
  });

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const SizedBox(height: 90);
    }

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 0.3,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final story = stories[index];
          return _storyItem(context, story);
        },
      ),
    );
  }

  Widget _storyItem(BuildContext context, Story story) {
    final bool viewed = story.isViewed;

    return GestureDetector(
      onTap: () {
        // open story viewer (step later)
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: viewed
                  ? null
                  : const LinearGradient(
                      colors: [
                        Color(0xFF9B2282),
                        Color(0xFFEEA863),
                      ],
                    ),
              border: viewed
                  ? Border.all(
                      color: AppColors.divider,
                      width: 1,
                    )
                  : null,
            ),
            child: Avatar(
              imageUrl: story.userAvatar,
              size: 64,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              story.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

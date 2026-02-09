// lib/widgets/post_header.dart

import 'package:flutter/material.dart';

import 'avatar.dart';
import 'verified_badge.dart';
import 'story_ring.dart';

class PostHeader extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final bool isVerified;
  final bool hasStory;
  final bool isStoryViewed;
  final VoidCallback? onProfileTap;
  final VoidCallback? onMoreTap;

  const PostHeader({
    super.key,
    required this.username,
    required this.avatarUrl,
    this.isVerified = false,
    this.hasStory = false,
    this.isStoryViewed = false,
    this.onProfileTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onProfileTap,
            child: hasStory
                ? StoryRing(
                    isViewed: isStoryViewed,
                    size: 42,
                    borderWidth: 2.5,
                    child: Avatar(
                      imageUrl: avatarUrl,
                      size: 36,
                    ),
                  )
                : Avatar(
                    imageUrl: avatarUrl,
                    size: 36,
                  ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: GestureDetector(
              onTap: onProfileTap,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (isVerified) ...[
                    const SizedBox(width: 4),
                    const VerifiedBadge(size: 14),
                  ],
                ],
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: onMoreTap,
          ),
        ],
      ),
    );
  }
}

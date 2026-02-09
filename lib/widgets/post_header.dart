// lib/widgets/post_header.dart
// =====================================================
// POST HEADER – FINAL v5
// Instagram-like, clean, build-safe
// =====================================================

import 'package:flutter/material.dart';

import 'avatar.dart';
import 'verified_badge.dart';
import 'story_ring.dart';

class PostHeader extends StatelessWidget {
  final String username;
  final String? avatarUrl;

  final bool isVerified;
  final bool hasStory;
  final bool isStoryViewed;

  final VoidCallback? onProfileTap;
  final VoidCallback? onMoreTap;

  const PostHeader({
    super.key,
    required this.username,
    this.avatarUrl,
    this.isVerified = false,
    this.hasStory = false,
    this.isStoryViewed = false,
    this.onProfileTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // ================= AVATAR / STORY =================
          InkWell(
            borderRadius: BorderRadius.circular(24),
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

          // ================= USERNAME + VERIFIED =================
          Expanded(
            child: InkWell(
              onTap: onProfileTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle,
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

          // ================= MORE BUTTON =================
          IconButton(
            icon: const Icon(Icons.more_vert),
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onMoreTap,
          ),
        ],
      ),
    );
  }
}

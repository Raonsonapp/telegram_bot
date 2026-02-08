import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../theme/colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/verified_badge.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          _media(),
          _actions(),
          _likes(),
          _caption(),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Avatar(
            imageUrl: post.userAvatar,
            size: 36,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  post.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (post.isUserVerified) ...[
                  const SizedBox(width: 4),
                  const VerifiedBadge(),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.more_vert,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ================= MEDIA =================
  Widget _media() {
    if (post.mediaUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Image.network(
        post.mediaUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            color: AppColors.divider,
            child: const Center(
              child: Icon(Icons.broken_image),
            ),
          );
        },
      ),
    );
  }

  // ================= ACTIONS =================
  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              post.isLiked ? Icons.favorite : Icons.favorite_border,
              color: post.isLiked ? Colors.red : null,
            ),
            onPressed: onLike,
          ),
          IconButton(
            icon: const Icon(Icons.mode_comment_outlined),
            onPressed: onComment,
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onShare,
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              post.isSaved ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: onSave,
          ),
        ],
      ),
    );
  }

  // ================= LIKES =================
  Widget _likes() {
    if (post.likesCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        '${post.likesCount} likes',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= CAPTION =================
  Widget _caption() {
    if (post.caption.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: '${post.username} ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: post.caption,
            ),
          ],
        ),
      ),
    );
  }
}

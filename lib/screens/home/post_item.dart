import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../widgets/avatar.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/loading.dart';
import 'post_actions.dart';

class PostItem extends StatelessWidget {
  const PostItem({
    super.key,
    required this.post,
    required this.onChanged,
  });

  final Post post;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          _media(),
          PostActions(post: post, onChanged: onChanged),
          _likes(),
          _caption(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return ListTile(
      leading: Avatar(url: post.userAvatar),
      title: Row(
        children: [
          Text(
            post.username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (post.isVerified) const SizedBox(width: 4),
          if (post.isVerified) const VerifiedBadge(),
        ],
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.white),
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
        fit: BoxFit.cover,
        loadingBuilder: (c, w, p) {
          if (p == null) return w;
          return const Center(child: Loading());
        },
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      ),
    );
  }

  // ================= LIKES =================
  Widget _likes() {
    if (post.likesCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '${post.likesCount} likes',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ================= CAPTION =================
  Widget _caption() {
    if (post.caption.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: '${post.username} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: post.caption),
          ],
        ),
      ),
    );
  }
}

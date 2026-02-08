import 'package:flutter/material.dart';

import '../../services/post_service.dart';
import '../comments/comments_screen.dart';

class PostItem extends StatelessWidget {
  final dynamic post;
  final String me;
  final VoidCallback onRefresh;

  const PostItem({
    super.key,
    required this.post,
    required this.me,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final int postId = post['id'];
    final String username = post['username'] ?? '';
    final String image = post['mediaUrl'] ?? '';
    final String caption = post['caption'] ?? '';
    final int likes = post['likesCount'] ?? 0;
    final bool liked = post['liked'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(username),
          trailing: const Icon(Icons.more_vert),
        ),

        // IMAGE
        if (image.isNotEmpty)
          Image.network(
            image,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const SizedBox(height: 250, child: Icon(Icons.broken_image)),
          ),

        // ACTIONS
        Row(
          children: [
            IconButton(
              icon: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? Colors.red : null,
              ),
              onPressed: () async {
                liked
                    ? await PostService.unlikePost(postId)
                    : await PostService.likePost(postId);
                onRefresh();
              },
            ),
            IconButton(
              icon: const Icon(Icons.mode_comment_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommentsScreen(postId: postId),
                  ),
                );
              },
            ),
            const IconButton(
              icon: Icon(Icons.send),
              onPressed: null,
            ),
          ],
        ),

        // LIKES
        if (likes > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$likes likes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

        // CAPTION
        if (caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                    text: '$username ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: caption),
                ],
              ),
            ),
          ),

        const Divider(),
      ],
    );
  }
}

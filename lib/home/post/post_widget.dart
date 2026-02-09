import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/post_model.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/media_viewer.dart';
import 'post_actions.dart';
import 'post_controller.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostController(post),
      child: Consumer<PostController>(
        builder: (context, controller, _) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AvatarWidget(imageUrl: post.avatarUrl, size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.username,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              post.location ?? 'Raonson',
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MediaViewer(url: post.imageUrl),
                  ),
                  const SizedBox(height: 12),
                  PostActions(
                    liked: post.liked,
                    saved: post.saved,
                    onLike: controller.toggleLike,
                    onComment: () {},
                    onShare: () {},
                    onSave: controller.toggleSave,
                  ),
                  Text(
                    '${post.likes} likes',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(
                          text: post.username,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: '  '),
                        TextSpan(text: post.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.timeAgo,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

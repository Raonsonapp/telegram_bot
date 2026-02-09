import 'package:flutter/material.dart';

class PostActions extends StatelessWidget {
  const PostActions({
    super.key,
    required this.liked,
    required this.saved,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
  });

  final bool liked;
  final bool saved;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
          color: liked ? Colors.pinkAccent : Colors.white,
          onPressed: onLike,
        ),
        IconButton(
          icon: const Icon(Icons.mode_comment_outlined),
          onPressed: onComment,
        ),
        IconButton(
          icon: const Icon(Icons.send_outlined),
          onPressed: onShare,
        ),
        const Spacer(),
        IconButton(
          icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
          onPressed: onSave,
        ),
      ],
    );
  }
}

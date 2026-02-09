import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../services/like_service.dart';
import '../../services/comment_service.dart';
import '../../widgets/icon_button.dart';
import '../../widgets/loading.dart';
import '../comments/comments_screen.dart';

class PostActions extends StatefulWidget {
  const PostActions({
    super.key,
    required this.post,
    required this.onChanged,
  });

  final Post post;
  final VoidCallback onChanged;

  @override
  State<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<PostActions> {
  bool _loading = false;

  Future<void> _like() async {
    setState(() => _loading = true);
    try {
      if (widget.post.isLiked) {
        await LikeService.unlike(widget.post.id);
      } else {
        await LikeService.like(widget.post.id);
      }
      widget.onChanged();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      if (widget.post.isSaved) {
        await PostService.unsave(widget.post.id);
      } else {
        await PostService.save(widget.post.id);
      }
      widget.onChanged();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openComments() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommentsScreen(postId: widget.post.id),
      ),
    );
  }

  void _share() {
    // MVP: server-side share not required
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Loading(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          /// LIKE
          AppIconButton(
            icon: widget.post.isLiked
                ? Icons.favorite
                : Icons.favorite_border,
            color: widget.post.isLiked ? Colors.red : null,
            onTap: _like,
          ),

          /// COMMENT
          AppIconButton(
            icon: Icons.mode_comment_outlined,
            onTap: _openComments,
          ),

          /// SHARE
          AppIconButton(
            icon: Icons.send,
            onTap: _share,
          ),

          const Spacer(),

          /// SAVE
          AppIconButton(
            icon: widget.post.isSaved
                ? Icons.bookmark
                : Icons.bookmark_border,
            onTap: _save,
          ),
        ],
      ),
    );
  }
}

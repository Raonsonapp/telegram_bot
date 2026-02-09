// lib/widgets/post_actions.dart
// =====================================================
// POST ACTIONS – FINAL v5
// Like / Comment / Save (build-safe)
// =====================================================

import 'package:flutter/material.dart';

import '../services/like_service.dart';
import '../services/post_service.dart';

class PostActions extends StatefulWidget {
  final int postId;
  final bool isLiked;
  final bool isSaved;
  final int likesCount;

  const PostActions({
    super.key,
    required this.postId,
    required this.isLiked,
    required this.isSaved,
    required this.likesCount,
  });

  @override
  State<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<PostActions> {
  late bool _liked;
  late bool _saved;
  late int _likes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _saved = widget.isSaved;
    _likes = widget.likesCount;
  }

  // ================= LIKE =================
  Future<void> _toggleLike() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      if (_liked) {
        await LikeService.unlike(
          type: 'post',
          id: widget.postId,
        );
        if (_likes > 0) _likes--;
      } else {
        await LikeService.like(
          type: 'post',
          id: widget.postId,
        );
        _likes++;
      }

      _liked = !_liked;
    } catch (_) {
      // ignore error (optimistic UI)
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  // ================= SAVE =================
  Future<void> _toggleSave() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      if (_saved) {
        await PostService.unsave(widget.postId);
      } else {
        await PostService.save(widget.postId);
      }

      _saved = !_saved;
    } catch (_) {}

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  // ================= SHARE =================
  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== ACTION ROW =====
        Row(
          children: [
            IconButton(
              onPressed: _toggleLike,
              icon: Icon(
                _liked ? Icons.favorite : Icons.favorite_border,
                color: _liked ? Colors.red : iconColor,
              ),
            ),
            IconButton(
              onPressed: () {
                // TODO: navigate to comments screen
              },
              icon: const Icon(Icons.mode_comment_outlined),
            ),
            IconButton(
              onPressed: _share,
              icon: const Icon(Icons.send),
            ),
            const Spacer(),
            IconButton(
              onPressed: _toggleSave,
              icon: Icon(
                _saved ? Icons.bookmark : Icons.bookmark_border,
                color: iconColor,
              ),
            ),
          ],
        ),

        // ===== LIKES COUNT =====
        if (_likes > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$_likes likes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
      ],
    );
  }
}

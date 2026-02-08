import 'package:flutter/material.dart';
import '../../services/post_service.dart';
import '../../core/session.dart';
import '../comments/comments_screen.dart';

class ReelActions extends StatefulWidget {
  final int postId;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;

  const ReelActions({
    super.key,
    required this.postId,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isSaved,
  });

  @override
  State<ReelActions> createState() => _ReelActionsState();
}

class _ReelActionsState extends State<ReelActions> {
  late bool _liked;
  late bool _saved;
  late int _likes;
  String _me = '';

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _saved = widget.isSaved;
    _likes = widget.likesCount;
    _loadMe();
  }

  Future<void> _loadMe() async {
    _me = await Session.username() ?? '';
  }

  Future<void> _toggleLike() async {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });

    try {
      if (_liked) {
        await PostService.likePost(widget.postId);
      } else {
        await PostService.unlikePost(widget.postId);
      }
    } catch (_) {
      // rollback on error
      setState(() {
        _liked = !_liked;
        _likes += _liked ? 1 : -1;
      });
    }
  }

  Future<void> _toggleSave() async {
    setState(() => _saved = !_saved);

    try {
      if (_saved) {
        await PostService.savePost(widget.postId);
      } else {
        await PostService.unsavePost(widget.postId);
      }
    } catch (_) {
      setState(() => _saved = !_saved);
    }
  }

  void _openComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentsScreen(postId: widget.postId),
      ),
    );
  }

  void _share() {
    // v1/v2: placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconButton(
          icon: _liked ? Icons.favorite : Icons.favorite_border,
          color: _liked ? Colors.red : Colors.white,
          label: _likes.toString(),
          onTap: _toggleLike,
        ),

        const SizedBox(height: 16),

        _iconButton(
          icon: Icons.mode_comment_outlined,
          label: widget.commentsCount.toString(),
          onTap: _openComments,
        ),

        const SizedBox(height: 16),

        _iconButton(
          icon: Icons.send,
          onTap: _share,
        ),

        const SizedBox(height: 16),

        _iconButton(
          icon: _saved ? Icons.bookmark : Icons.bookmark_border,
          onTap: _toggleSave,
        ),
      ],
    );
  }

  Widget _iconButton({
    required IconData icon,
    Color color = Colors.white,
    String? label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

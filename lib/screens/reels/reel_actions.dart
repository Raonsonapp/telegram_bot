import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../services/reel_service.dart';
import '../comments/comments_screen.dart';

class ReelActions extends StatefulWidget {
  final int reelId;
  final int likes;
  final bool isLiked;
  final bool isSaved;

  const ReelActions({
    super.key,
    required this.reelId,
    required this.likes,
    required this.isLiked,
    required this.isSaved,
  });

  @override
  State<ReelActions> createState() => _ReelActionsState();
}

class _ReelActionsState extends State<ReelActions> {
  late bool _liked;
  late bool _saved;
  late int _likesCount;
  String _me = '';

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _saved = widget.isSaved;
    _likesCount = widget.likes;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await Session.username() ?? '';
    setState(() => _me = u);
  }

  // ================= LIKE =================
  Future<void> _toggleLike() async {
    if (_liked) {
      await ReelService.unlike(widget.reelId);
      setState(() {
        _liked = false;
        _likesCount--;
      });
    } else {
      await ReelService.like(widget.reelId);
      setState(() {
        _liked = true;
        _likesCount++;
      });
    }
  }

  // ================= SAVE =================
  Future<void> _toggleSave() async {
    if (_saved) {
      await ReelService.unsave(widget.reelId);
      setState(() => _saved = false);
    } else {
      await ReelService.save(widget.reelId);
      setState(() => _saved = true);
    }
  }

  // ================= COMMENT =================
  void _openComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentsScreen(postId: widget.reelId),
      ),
    );
  }

  // ================= SHARE =================
  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _icon(
          icon: _liked ? Icons.favorite : Icons.favorite_border,
          color: _liked ? Colors.red : Colors.white,
          label: _likesCount.toString(),
          onTap: _toggleLike,
        ),
        const SizedBox(height: 16),
        _icon(
          icon: Icons.mode_comment_outlined,
          label: 'Comment',
          onTap: _openComments,
        ),
        const SizedBox(height: 16),
        _icon(
          icon: _saved ? Icons.bookmark : Icons.bookmark_border,
          label: 'Save',
          onTap: _toggleSave,
        ),
        const SizedBox(height: 16),
        _icon(
          icon: Icons.send,
          label: 'Share',
          onTap: _share,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _icon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

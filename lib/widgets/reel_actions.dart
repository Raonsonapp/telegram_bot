// lib/widgets/reel_actions.dart

import 'package:flutter/material.dart';

import '../services/reel_service.dart';

class ReelActions extends StatefulWidget {
  final int reelId;
  final bool isLiked;
  final bool isSaved;
  final int likesCount;
  final VoidCallback? onCommentTap;

  const ReelActions({
    super.key,
    required this.reelId,
    required this.isLiked,
    required this.isSaved,
    required this.likesCount,
    this.onCommentTap,
  });

  @override
  State<ReelActions> createState() => _ReelActionsState();
}

class _ReelActionsState extends State<ReelActions> {
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
        await ReelService.unlike(widget.reelId);
        _likes--;
      } else {
        await ReelService.like(widget.reelId);
        _likes++;
      }
      _liked = !_liked;
    } catch (_) {}

    setState(() => _loading = false);
  }

  // ================= SAVE =================
  Future<void> _toggleSave() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      if (_saved) {
        await ReelService.unsave(widget.reelId);
      } else {
        await ReelService.save(widget.reelId);
      }
      _saved = !_saved;
    } catch (_) {}

    setState(() => _loading = false);
  }

  // ================= SHARE =================
  void _share() {
    // Placeholder — баъд ShareService илова мекунем
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // ===== LIKE =====
        IconButton(
          onPressed: _toggleLike,
          icon: Icon(
            _liked ? Icons.favorite : Icons.favorite_border,
            color: _liked ? Colors.red : Colors.white,
            size: 28,
          ),
        ),
        if (_likes > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '$_likes',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // ===== COMMENT =====
        IconButton(
          onPressed: widget.onCommentTap,
          icon: const Icon(
            Icons.mode_comment_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 12),

        // ===== SHARE =====
        IconButton(
          onPressed: _share,
          icon: const Icon(
            Icons.send,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 12),

        // ===== SAVE =====
        IconButton(
          onPressed: _toggleSave,
          icon: Icon(
            _saved ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

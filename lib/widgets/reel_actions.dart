import 'package:flutter/material.dart';

import '../models/reel.dart';
import '../services/reel_service.dart';

class ReelActions extends StatefulWidget {
  final Reel reel;
  final VoidCallback onChanged;
  final VoidCallback? onCommentTap;

  const ReelActions({
    super.key,
    required this.reel,
    required this.onChanged,
    this.onCommentTap,
  });

  @override
  State<ReelActions> createState() => _ReelActionsState();
}

class _ReelActionsState extends State<ReelActions> {
  bool _loading = false;

  Reel get _reel => widget.reel;

  // ================= LIKE =================
  Future<void> _toggleLike() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      if (_reel.isLiked) {
        await ReelService.unlike(_reel.id);
      } else {
        await ReelService.like(_reel.id);
      }
      widget.onChanged();
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  // ================= SAVE =================
  Future<void> _toggleSave() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      if (_reel.isSaved) {
        await ReelService.unsave(_reel.id);
      } else {
        await ReelService.save(_reel.id);
      }
      widget.onChanged();
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  // ================= SHARE =================
  void _share() {
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
            _reel.isLiked ? Icons.favorite : Icons.favorite_border,
            color: _reel.isLiked ? Colors.red : Colors.white,
            size: 28,
          ),
        ),
        if (_reel.likesCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${_reel.likesCount}',
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
            _reel.isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

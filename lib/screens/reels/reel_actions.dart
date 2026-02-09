import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../services/reel_service.dart';
import '../../widgets/verified_badge.dart';

/// Reels Actions Widget
/// Like • Comment • Share • Save
/// Version: v5 FULL
class ReelActions extends StatefulWidget {
  final int reelId;
  final String username;
  final bool isVerified;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onCommentTap;

  const ReelActions({
    super.key,
    required this.reelId,
    required this.username,
    required this.isVerified,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isSaved,
    required this.onCommentTap,
  });

  @override
  State<ReelActions> createState() => _ReelActionsState();
}

class _ReelActionsState extends State<ReelActions> {
  late bool _liked;
  late bool _saved;
  late int _likes;
  bool _loadingLike = false;
  bool _loadingSave = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _saved = widget.isSaved;
    _likes = widget.likesCount;
  }

  // =====================================================
  // ACTIONS
  // =====================================================
  Future<void> _toggleLike() async {
    if (_loadingLike) return;
    _loadingLike = true;

    try {
      if (_liked) {
        await ReelService.unlike(widget.reelId);
        setState(() {
          _liked = false;
          _likes--;
        });
      } else {
        await ReelService.like(widget.reelId);
        setState(() {
          _liked = true;
          _likes++;
        });
      }
    } finally {
      _loadingLike = false;
    }
  }

  Future<void> _toggleSave() async {
    if (_loadingSave) return;
    _loadingSave = true;

    try {
      if (_saved) {
        await ReelService.unsave(widget.reelId);
        setState(() => _saved = false);
      } else {
        await ReelService.save(widget.reelId);
        setState(() => _saved = true);
      }
    } finally {
      _loadingSave = false;
    }
  }

  void _share() {
    // backend / native share later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share coming soon')),
    );
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _iconButton(
          icon: _liked ? Icons.favorite : Icons.favorite_border,
          color: _liked ? Colors.red : Colors.white,
          onTap: _toggleLike,
          label: _likes.toString(),
        ),
        const SizedBox(height: 18),
        _iconButton(
          icon: Icons.mode_comment_outlined,
          onTap: widget.onCommentTap,
          label: widget.commentsCount.toString(),
        ),
        const SizedBox(height: 18),
        _iconButton(
          icon: Icons.send,
          onTap: _share,
        ),
        const SizedBox(height: 18),
        _iconButton(
          icon: _saved ? Icons.bookmark : Icons.bookmark_border,
          onTap: _toggleSave,
        ),
        const SizedBox(height: 26),
        _userInfo(),
      ],
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? label,
    Color color = Colors.white,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, size: 32, color: color),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _userInfo() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white12,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (widget.isVerified) ...[
              const SizedBox(width: 4),
              const VerifiedBadge(size: 12),
            ],
          ],
        ),
      ],
    );
  }
}

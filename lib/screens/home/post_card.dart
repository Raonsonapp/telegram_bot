import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../widgets/post_header.dart';
import '../../widgets/post_media.dart';
import '../../widgets/post_actions.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.me,
    required this.onDeleted,
  });

  final Post post;
  final String me;
  final VoidCallback onDeleted;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Post _post;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  Future<void> _refresh() async {
    final updated = await PostService.getPostById(_post.id);
    if (!mounted) return;
    setState(() => _post = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostHeader(
          username: _post.username,
          avatarUrl: _post.avatar,
          isVerified: _post.isVerified,
          onMore: _openMenu,
        ),

        PostMedia(
          mediaUrl: _post.mediaUrl,
        ),

        PostActions(
          postId: _post.id,
          liked: _post.isLiked,
          saved: _post.isSaved,
          likesCount: _post.likesCount,
          loading: _busy,
          onLike: _like,
          onUnlike: _unlike,
          onSave: _save,
          onUnsave: _unsave,
          onComment: () {
            Navigator.pushNamed(
              context,
              '/comments',
              arguments: _post.id,
            );
          },
          onShare: () {},
        ),

        _caption(),

        const SizedBox(height: 14),
      ],
    );
  }

  // ================= CAPTION =================

  Widget _caption() {
    if (_post.caption.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: '${_post.username} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: _post.caption),
          ],
        ),
      ),
    );
  }

  // ================= ACTIONS =================

  Future<void> _like() async {
    if (_busy) return;
    setState(() => _busy = true);
    await PostService.likePost(_post.id);
    await _refresh();
    setState(() => _busy = false);
  }

  Future<void> _unlike() async {
    if (_busy) return;
    setState(() => _busy = true);
    await PostService.unlikePost(_post.id);
    await _refresh();
    setState(() => _busy = false);
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    await PostService.savePost(_post.id);
    await _refresh();
    setState(() => _busy = false);
  }

  Future<void> _unsave() async {
    if (_busy) return;
    setState(() => _busy = true);
    await PostService.unsavePost(_post.id);
    await _refresh();
    setState(() => _busy = false);
  }

  // ================= MENU =================

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetItem(
                icon: Icons.report,
                label: 'Report',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/report',
                    arguments: _post.id,
                  );
                },
              ),
              if (_post.username == widget.me)
                _sheetItem(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  danger: true,
                  onTap: _delete,
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete() async {
    Navigator.pop(context);
    await PostService.deletePost(_post.id);
    widget.onDeleted();
  }

  Widget _sheetItem({
    required IconData icon,
    required String label,
    bool danger = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: danger ? Colors.redAccent : Colors.white,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: danger ? Colors.redAccent : Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}

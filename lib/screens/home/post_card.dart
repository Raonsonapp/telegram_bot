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

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostHeader(
          username: _post.user.username,
          avatarUrl: _post.user.avatarUrl ?? '',
          isVerified: _post.user.isVerified,
          onMoreTap: _openMenu,
        ),

        PostMedia(
          mediaUrl: _post.mediaUrl,
          isVideo: _post.isVideo,
        ),

        PostActions(
          postId: _post.id,
          isLiked: _post.isLiked,
          isSaved: _post.isSaved,
          likesCount: _post.likesCount,
        ),

        if (_post.hasCaption) _caption(),

        const SizedBox(height: 14),
      ],
    );
  }

  // ================= CAPTION =================

  Widget _caption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: '${_post.user.username} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: _post.caption),
          ],
        ),
      ),
    );
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
              if (_post.user.username == widget.me)
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
    await PostService.delete(_post.id);
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

import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/post_header.dart';
import '../../widgets/post_media.dart';
import '../../widgets/post_actions.dart';

class FeedList extends StatefulWidget {
  const FeedList({
    super.key,
    required this.me,
  });

  final String me;

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  bool _loading = true;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    if (mounted) setState(() => _loading = true);

    try {
      final data = await PostService.getFeed();
      if (mounted) {
        setState(() => _posts = data);
      }
    } catch (_) {
      // handled by empty state
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: AppLoading());
    }

    if (_posts.isEmpty) {
      return const EmptyState(
        icon: Icons.image_outlined,
        title: 'No posts yet',
        subtitle: 'Follow people to see posts here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      color: Colors.white,
      backgroundColor: Colors.black,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _postItem(post);
        },
      ),
    );
  }

  // ================= POST ITEM =================

  Widget _postItem(Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostHeader(
          username: post.user.username,
          avatarUrl: post.user.avatarUrl ?? '',
          isVerified: post.user.isVerified,
          onMoreTap: () => _openPostMenu(post),
        ),

        PostMedia(
          mediaUrl: post.mediaUrl,
          isVideo: post.isVideo,
        ),

        PostActions(
          postId: post.id,
          isLiked: post.isLiked,
          isSaved: post.isSaved,
          likesCount: post.likesCount,
        ),

        if (post.hasCaption) _caption(post),

        const SizedBox(height: 14),
      ],
    );
  }

  Widget _caption(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: '${post.user.username} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: post.caption),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  void _openPostMenu(Post post) {
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
                    arguments: post.id,
                  );
                },
              ),
              if (post.user.username == widget.me)
                _sheetItem(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  danger: true,
                  onTap: () async {
                    Navigator.pop(context);
                    await PostService.delete(post.id);
                    _loadFeed();
                  },
                ),
            ],
          ),
        );
      },
    );
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

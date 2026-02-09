import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/post_header.dart';
import '../../widgets/post_media.dart';
import '../../widgets/post_actions.dart';
import 'story_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<Post> _posts = [];
  String _me = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final u = await Session.getUsername();
    _me = u ?? '';
    await _loadFeed();
  }

  Future<void> _loadFeed() async {
    if (mounted) setState(() => _loading = true);

    try {
      final data = await PostService.getFeed();
      if (mounted) {
        setState(() {
          _posts = data;
        });
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(),
      body: _loading
          ? const AppLoading()
          : RefreshIndicator(
              onRefresh: _loadFeed,
              color: Colors.white,
              backgroundColor: Colors.black,
              child: _posts.isEmpty
                  ? const EmptyState(
                      icon: Icons.image_outlined,
                      title: 'No posts yet',
                      subtitle: 'Follow people to see posts here',
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return StoryBar(me: _me);
                        }
                        return _postItem(_posts[index - 1]);
                      },
                    ),
            ),
    );
  }

  // ================= APP BAR =================

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        'Raonson',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: const [
        Icon(Icons.favorite_border),
        SizedBox(width: 12),
        Icon(Icons.smart_toy_outlined),
        SizedBox(width: 12),
      ],
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

        const SizedBox(height: 12),
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
}

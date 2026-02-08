import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../services/post_service.dart';
import '../../services/post_actions_service.dart';
import '../comments/comments_screen.dart';
import '../create/create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _posts = [];
  String _me = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _me = await Session.username() ?? '';
    await _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() => _loading = true);
    try {
      final data = await PostService.getFeedPosts();
      _posts = List<Map<String, dynamic>>.from(data);
    } catch (_) {}
    setState(() => _loading = false);
  }

  // ========================= UI =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: _appBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _posts.length,
                itemBuilder: (_, i) => _postCard(_posts[i]),
              ),
            ),
    );
  }

  // ========================= APP BAR =========================

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F1424),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.add_box_outlined),
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
          if (ok == true) _loadFeed();
        },
      ),
      title: const Text(
        'Raonson',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.smart_toy_outlined), // Jarvis
          onPressed: () {},
        ),
      ],
    );
  }

  // ========================= POST CARD =========================

  Widget _postCard(Map<String, dynamic> post) {
    int postId = post['id'];
    String username = post['username'] ?? '';
    String caption = post['caption'] ?? '';
    String mediaUrl = post['mediaUrl'] ?? '';
    int likes = post['likes'] ?? 0;

    bool isLiked = false;

    return StatefulBuilder(
      builder: (context, setLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.more_vert),
            ),

            // IMAGE
            if (mediaUrl.isNotEmpty)
              Image.network(
                mediaUrl,
                width: double.infinity,
                height: 360,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 360,
                  color: Colors.black26,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),

            // ACTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white,
                    ),
                    onPressed: () async {
                      if (isLiked) {
                        likes = await PostActionsService.unlike(postId, likes);
                      } else {
                        likes = await PostActionsService.like(postId, likes);
                      }
                      setLocal(() => isLiked = !isLiked);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.mode_comment_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CommentsScreen(postId: postId),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {},
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // LIKES
            if (likes > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '$likes likes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

            // CAPTION
            if (caption.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: '$username ',
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: caption),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

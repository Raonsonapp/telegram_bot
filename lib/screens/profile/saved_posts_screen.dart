import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import '../home/post_card.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  bool _loading = true;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    setState(() => _loading = true);

    try {
      final data = await PostService.getSavedPosts();
      setState(() {
        _posts = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _openPost(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: ListView(
            children: [
              PostCard(post: post),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridItem(Post post) {
    return GestureDetector(
      onTap: () => _openPost(post),
      child: Container(
        color: Colors.black12,
        child: post.mediaUrl.isNotEmpty
            ? Image.network(
                post.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image),
              )
            : const Icon(Icons.image_not_supported),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
      ),
      body: _loading
          ? const Loading()
          : _posts.isEmpty
              ? const EmptyState(
                  icon: Icons.bookmark_border,
                  title: 'No saved posts',
                  subtitle: 'Save posts to see them here',
                )
              : RefreshIndicator(
                  onRefresh: _loadSaved,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(1),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemCount: _posts.length,
                    itemBuilder: (_, i) => _gridItem(_posts[i]),
                  ),
                ),
    );
  }
}

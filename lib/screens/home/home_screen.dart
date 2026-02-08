import 'package:flutter/material.dart';

import '../../services/post_service.dart';
import '../../services/story_service.dart';
import '../../models/post.dart';
import '../../models/story.dart';
import '../../theme/colors.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';

import 'story_bar.dart';
import 'post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<Post> _posts = [];
  List<Story> _stories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final posts = await PostService.getFeedPosts();
      final stories = await StoryService.getStories();

      setState(() {
        _posts = posts;
        _stories = stories;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar(),
      body: _loading
          ? const Loading()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: _posts.isEmpty
                  ? const EmptyState(
                      icon: Icons.image_not_supported_outlined,
                      title: 'No posts yet',
                    )
                  : ListView.builder(
                      itemCount: _posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return StoryBar(stories: _stories);
                        }

                        final post = _posts[index - 1];
                        return PostCard(
                          post: post,
                          onLike: () async {
                            await PostService.likePost(post.id);
                            _loadData();
                          },
                          onUnlike: () async {
                            await PostService.unlikePost(post.id);
                            _loadData();
                          },
                          onSave: () async {
                            await PostService.savePost(post.id);
                          },
                          onComment: () {
                            // comments screen later
                          },
                        );
                      },
                    ),
            ),
    );
  }

  // ================= APP BAR =================
  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Raonson',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.add_box_outlined),
        onPressed: () {
          // create post (step later)
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.smart_toy_outlined), // Jarvis
          onPressed: () {},
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../services/follow_service.dart';
import '../../core/session.dart';
import '../comments/comments_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  final List<Post> _reels = [];
  final Map<int, VideoPlayerController> _controllers = {};

  bool _loading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  Future<void> _loadReels() async {
    try {
      final data = await PostService.getReels();
      _reels.clear();
      _reels.addAll(data);

      for (int i = 0; i < _reels.length; i++) {
        _initController(i);
      }

      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _initController(int index) async {
    final reel = _reels[index];
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(reel.mediaUrl),
    );

    await controller.initialize();
    controller.setLooping(true);

    _controllers[index] = controller;

    if (index == 0) {
      controller.play();
    }

    setState(() {});
  }

  void _onPageChanged(int index) {
    if (_controllers[_currentIndex] != null) {
      _controllers[_currentIndex]!.pause();
    }

    _currentIndex = index;

    if (_controllers[_currentIndex] != null) {
      _controllers[_currentIndex]!.play();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reels.isEmpty) {
      return const Center(child: Text('No reels'));
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: _onPageChanged,
      itemCount: _reels.length,
      itemBuilder: (context, index) {
        return _reelItem(_reels[index], index);
      },
    );
  }

  Widget _reelItem(Post reel, int index) {
    final controller = _controllers[index];

    return Stack(
      children: [
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? VideoPlayer(controller)
              : const Center(child: CircularProgressIndicator()),
        ),

        /// ================= BOTTOM INFO =================
        Positioned(
          left: 16,
          bottom: 24,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${reel.username}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                reel.caption,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        /// ================= ACTIONS =================
        Positioned(
          right: 12,
          bottom: 80,
          child: Column(
            children: [
              _actionButton(
                icon: reel.isLiked
                    ? Icons.favorite
                    : Icons.favorite_border,
                label: '${reel.likesCount}',
                color: reel.isLiked ? Colors.red : Colors.white,
                onTap: () async {
                  if (reel.isLiked) {
                    await PostService.unlikePost(reel.id);
                  } else {
                    await PostService.likePost(reel.id);
                  }
                  setState(() => reel.isLiked = !reel.isLiked);
                },
              ),
              const SizedBox(height: 20),
              _actionButton(
                icon: Icons.mode_comment_outlined,
                label: '${reel.commentsCount}',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(postId: reel.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _actionButton(
                icon: Icons.send,
                label: 'Share',
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _actionButton(
                icon: reel.isSaved
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                label: 'Save',
                onTap: () async {
                  if (reel.isSaved) {
                    await PostService.unsavePost(reel.id);
                  } else {
                    await PostService.savePost(reel.id);
                  }
                  setState(() => reel.isSaved = !reel.isSaved);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

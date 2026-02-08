import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../services/post_service.dart';
import '../comments/comments_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  List<dynamic> _reels = [];
  int _currentIndex = 0;
  bool _loading = true;

  final Map<int, VideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReels() async {
    try {
      final data = await PostService.getReels();
      _reels = data;
      _loading = false;

      if (_reels.isNotEmpty) {
        await _initController(0);
      }
      setState(() {});
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _initController(int index) async {
    if (_controllers.containsKey(index)) return;

    final url = _reels[index]['media_url'];
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller.setLooping(true);

    _controllers[index] = controller;

    if (index == _currentIndex) {
      controller.play();
    }
  }

  void _onPageChanged(int index) async {
    // stop old
    _controllers[_currentIndex]?.pause();

    _currentIndex = index;
    await _initController(index);

    _controllers[index]?.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: _onPageChanged,
              itemCount: _reels.length,
              itemBuilder: (_, index) {
                return _reelItem(index);
              },
            ),
    );
  }

  // ===================== SINGLE REEL =====================
  Widget _reelItem(int index) {
    final reel = _reels[index];
    final controller = _controllers[index];

    final int postId = reel['id'];
    final String username = reel['username'] ?? '';
    final String caption = reel['caption'] ?? '';
    final int likes = reel['likes'] ?? 0;
    final bool liked = reel['liked'] ?? false;
    final bool saved = reel['saved'] ?? false;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ===== VIDEO =====
        controller == null || !controller.value.isInitialized
            ? const Center(child: CircularProgressIndicator())
            : GestureDetector(
                onTap: () {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                  setState(() {});
                },
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),

        // ===== LEFT INFO =====
        Positioned(
          left: 12,
          bottom: 80,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@$username',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                caption,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),

        // ===== RIGHT ACTIONS =====
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              _actionButton(
                icon: liked ? Icons.favorite : Icons.favorite_border,
                label: likes.toString(),
                color: liked ? Colors.red : Colors.white,
                onTap: () async {
                  liked
                      ? await PostService.unlikePost(postId)
                      : await PostService.likePost(postId);
                  _loadReels();
                },
              ),
              const SizedBox(height: 18),
              _actionButton(
                icon: Icons.mode_comment_outlined,
                label: '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(postId: postId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              _actionButton(
                icon: saved ? Icons.bookmark : Icons.bookmark_border,
                label: '',
                onTap: () async {
                  saved
                      ? await PostService.unsavePost(postId)
                      : await PostService.savePost(postId);
                  _loadReels();
                },
              ),
              const SizedBox(height: 18),
              _actionButton(
                icon: Icons.send,
                label: '',
                onTap: () {},
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
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 30),
          onPressed: onTap,
        ),
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
      ],
    );
  }
}

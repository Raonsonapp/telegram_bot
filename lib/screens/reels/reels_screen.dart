import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  final List<String> _videos = [
    // mock urls (баъд аз server меояд)
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          return ReelItem(videoUrl: _videos[index]);
        },
      ),
    );
  }
}

// ================= SINGLE REEL =================

class ReelItem extends StatefulWidget {
  final String videoUrl;
  const ReelItem({super.key, required this.videoUrl});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  bool _liked = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // VIDEO
        Positioned.fill(
          child: _controller.value.isInitialized
              ? VideoPlayer(_controller)
              : const Center(child: CircularProgressIndicator()),
        ),

        // OVERLAY
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),

        // RIGHT ACTIONS
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              _action(
                icon: _liked ? Icons.favorite : Icons.favorite_border,
                color: _liked ? Colors.red : Colors.white,
                onTap: () => setState(() => _liked = !_liked),
              ),
              const SizedBox(height: 16),
              _action(
                icon: Icons.mode_comment_outlined,
                onTap: () {
                  // ҚАДАМИ 31 → Comments modal
                },
              ),
              const SizedBox(height: 16),
              _action(icon: Icons.send),
              const SizedBox(height: 16),
              _action(
                icon: _saved ? Icons.bookmark : Icons.bookmark_border,
                onTap: () => setState(() => _saved = !_saved),
              ),
            ],
          ),
        ),

        // BOTTOM INFO
        Positioned(
          left: 12,
          bottom: 24,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Text(
                    '@raonson',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.verified, size: 16, color: Colors.green),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Reels demo caption for Raonson 🔥',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _action({
    required IconData icon,
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 32, color: color),
    );
  }
}

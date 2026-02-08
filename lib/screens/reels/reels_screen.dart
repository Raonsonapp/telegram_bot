import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 1);

  // Ҳоло mock data — дар қадами сервер иваз мешавад
  final List<Map<String, dynamic>> _reels = [
    {
      "id": 1,
      "username": "raonson",
      "video":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      "caption": "Raonson reels test",
      "likes": 124,
      "liked": false,
    },
    {
      "id": 2,
      "username": "jarvis",
      "video":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "caption": "Second reel",
      "likes": 89,
      "liked": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        itemBuilder: (context, index) {
          return _ReelItem(
            data: _reels[index],
            onLike: () {
              setState(() {
                _reels[index]["liked"] = !_reels[index]["liked"];
                _reels[index]["likes"] +=
                    _reels[index]["liked"] ? 1 : -1;
              });
            },
          );
        },
      ),
    );
  }
}

// ================= SINGLE REEL =================

class _ReelItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onLike;

  const _ReelItem({
    required this.data,
    required this.onLike,
  });

  @override
  State<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<_ReelItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.data["video"])
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
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
        // ===== VIDEO =====
        Positioned.fill(
          child: _controller.value.isInitialized
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: VideoPlayer(_controller),
                )
              : const Center(child: CircularProgressIndicator()),
        ),

        // ===== RIGHT ACTIONS =====
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              IconButton(
                icon: Icon(
                  widget.data["liked"]
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color:
                      widget.data["liked"] ? Colors.red : Colors.white,
                  size: 32,
                ),
                onPressed: widget.onLike,
              ),
              Text(
                "${widget.data["likes"]}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 18),
              IconButton(
                icon: const Icon(Icons.mode_comment_outlined,
                    color: Colors.white, size: 30),
                onPressed: () {
                  // Қадамҳои оянда: CommentsScreen
                },
              ),
              const SizedBox(height: 18),
              IconButton(
                icon: const Icon(Icons.send,
                    color: Colors.white, size: 28),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // ===== BOTTOM INFO =====
        Positioned(
          left: 12,
          bottom: 40,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "@${widget.data["username"]}",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                widget.data["caption"],
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

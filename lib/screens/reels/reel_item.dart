import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../services/reel_service.dart';
import '../comments/comments_screen.dart';

class ReelItem extends StatefulWidget {
  final dynamic reel;
  const ReelItem({super.key, required this.reel});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.reel['is_liked'] ?? false;
    _controller = VideoPlayerController.network(widget.reel['video_url'])
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
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

        // RIGHT ACTIONS
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              IconButton(
                icon: Icon(
                  _liked ? Icons.favorite : Icons.favorite_border,
                  color: _liked ? Colors.red : Colors.white,
                  size: 32,
                ),
                onPressed: () async {
                  setState(() => _liked = !_liked);
                  _liked
                      ? await ReelService.like(widget.reel['id'])
                      : await ReelService.unlike(widget.reel['id']);
                },
              ),
              const SizedBox(height: 12),
              IconButton(
                icon: const Icon(Icons.comment, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CommentsScreen(postId: widget.reel['id']),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 28),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // USER + CAPTION
        Positioned(
          left: 12,
          bottom: 40,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.reel['username'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.reel['caption'] ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

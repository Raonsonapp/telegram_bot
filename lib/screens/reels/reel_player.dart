import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/loading.dart';

class ReelPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;

  const ReelPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
  });

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showPlayIcon = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    await _controller.initialize();
    _controller.setLooping(true);

    if (widget.autoPlay) {
      await _controller.play();
    }

    setState(() {
      _initialized = true;
      _showPlayIcon = !_controller.value.isPlaying;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_initialized) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _showPlayIcon = true);
    } else {
      _controller.play();
      setState(() => _showPlayIcon = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: Loading());
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ===== VIDEO =====
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          // ===== PLAY ICON =====
          AnimatedOpacity(
            opacity: _showPlayIcon ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 56,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

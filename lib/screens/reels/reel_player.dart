import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoplay;

  const ReelPlayer({
    super.key,
    required this.videoUrl,
    this.autoplay = true,
  });

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _muted = false;

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

    if (widget.autoplay) {
      _controller.play();
    }

    setState(() {
      _initialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void play() {
    if (_initialized) _controller.play();
  }

  void pause() {
    if (_initialized) _controller.pause();
  }

  void toggleMute() {
    if (!_initialized) return;
    setState(() {
      _muted = !_muted;
      _controller.setVolume(_muted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        if (_controller.value.isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
      },
      onLongPress: toggleMute,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          /// ▶ Play icon overlay
          if (!_controller.value.isPlaying)
            const Icon(
              Icons.play_arrow,
              size: 80,
              color: Colors.white70,
            ),

          /// 🔇 Mute indicator
          Positioned(
            top: 40,
            right: 16,
            child: Icon(
              _muted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

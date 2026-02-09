// lib/widgets/post_media.dart
// =====================================================
// POST MEDIA – FINAL v5
// Image & Video (Instagram-style, build-safe)
// =====================================================

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostMedia extends StatefulWidget {
  final String mediaUrl;
  final bool isVideo;
  final bool autoPlay;

  const PostMedia({
    super.key,
    required this.mediaUrl,
    this.isVideo = false,
    this.autoPlay = false,
  });

  @override
  State<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _muted = true;

  @override
  void initState() {
    super.initState();

    if (widget.isVideo) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaUrl),
      )
        ..setLooping(true)
        ..setVolume(0)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() => _initialized = true);

          if (widget.autoPlay) {
            _controller!.play();
          }
        });
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isVideo ? _buildVideo() : _buildImage();
  }

  // =====================================================
  // IMAGE
  // =====================================================
  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 1,
      child: Image.network(
        widget.mediaUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, size: 40),
        ),
      ),
    );
  }

  // =====================================================
  // VIDEO
  // =====================================================
  Widget _buildVideo() {
    if (_controller == null || !_initialized) {
      return const AspectRatio(
        aspectRatio: 9 / 16,
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final isPlaying = _controller!.value.isPlaying;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isPlaying) {
            _controller!.pause();
          } else {
            _controller!.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),

          // ▶ Play icon
          if (!isPlaying)
            const Icon(
              Icons.play_circle_fill,
              size: 64,
              color: Colors.white70,
            ),

          // 🔊 Mute button
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _muted = !_muted;
                  _controller!.setVolume(_muted ? 0 : 1);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _muted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

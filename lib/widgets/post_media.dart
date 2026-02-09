// lib/widgets/post_media.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostMedia extends StatefulWidget {
  /// URL-и медиа (акс ё видео)
  final String mediaUrl;

  /// Навъи медиа
  /// true = video, false = image
  final bool isVideo;

  /// Оё видео autoPlay шавад
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

  @override
  void initState() {
    super.initState();

    if (widget.isVideo) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaUrl),
      )..initialize().then((_) {
          if (!mounted) return;
          setState(() {
            _initialized = true;
          });

          if (widget.autoPlay) {
            _controller!.play();
            _controller!.setLooping(true);
          }
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVideo) {
      return _buildVideo();
    }
    return _buildImage();
  }

  // ================= IMAGE =================
  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 1,
      child: Image.network(
        widget.mediaUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(Icons.broken_image, size: 40),
          );
        },
      ),
    );
  }

  // ================= VIDEO =================
  Widget _buildVideo() {
    if (_controller == null || !_initialized) {
      return const AspectRatio(
        aspectRatio: 9 / 16,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),

          if (!_controller!.value.isPlaying)
            const Icon(
              Icons.play_circle_fill,
              size: 64,
              color: Colors.white70,
            ),
        ],
      ),
    );
  }
}

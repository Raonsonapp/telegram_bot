import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/post.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/loading.dart';
import '../../widgets/reel_actions.dart';

/// ReelItem
/// --------------------------------------------------
/// Намоиши 1 Reel (видео):
/// - autoplay
/// - loop
/// - overlay UI (username, caption)
/// - actions (like, comment, save)
///
/// Version: v5 FULL
class ReelItem extends StatefulWidget {
  final Post reel;
  final bool isActive; // барои autoplay ҳангоми scroll

  const ReelItem({
    super.key,
    required this.reel,
    required this.isActive,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.mediaUrl),
    );

    await _controller.initialize();
    _controller.setLooping(true);

    if (widget.isActive) {
      _controller.play();
    }

    setState(() {
      _ready = true;
    });
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // autoplay / pause ҳангоми scroll
    if (widget.isActive && !_controller.value.isPlaying) {
      _controller.play();
    } else if (!widget.isActive && _controller.value.isPlaying) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: Loading());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // ===== VIDEO =====
        GestureDetector(
          onTap: () {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          },
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),

        // ===== GRADIENT OVERLAY =====
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black87,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // ===== INFO (USERNAME + CAPTION) =====
        Positioned(
          left: 12,
          bottom: 20,
          right: 80,
          child: _Info(reel: widget.reel),
        ),

        // ===== ACTIONS =====
        Positioned(
          right: 8,
          bottom: 40,
          child: ReelActions(reel: widget.reel),
        ),
      ],
    );
  }
}

///
/// INFO BLOCK
///
class _Info extends StatelessWidget {
  final Post reel;

  const _Info({required this.reel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              '@${reel.username}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            if (reel.isVerified) const VerifiedBadge(),
          ],
        ),
        const SizedBox(height: 6),
        if (reel.caption.isNotEmpty)
          Text(
            reel.caption,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
      ],
    );
  }
}

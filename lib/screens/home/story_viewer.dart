import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/story.dart';
import '../../services/story_service.dart';
import '../../widgets/avatar.dart';

class StoryViewer extends StatefulWidget {
  const StoryViewer({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  final List<Story> stories;
  final int initialIndex;

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  late int _index;
  late AnimationController _progress;
  Timer? _timer;

  static const Duration _storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;

    _progress = AnimationController(
      vsync: this,
      duration: _storyDuration,
    )..addStatusListener(_onProgressStatus);

    _markViewed();
    _start();
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _next();
    }
  }

  void _start() {
    _progress.forward(from: 0);
  }

  void _pause() {
    _progress.stop();
  }

  void _resume() {
    if (!_progress.isAnimating) {
      _progress.forward();
    }
  }

  void _next() {
    if (_index < widget.stories.length - 1) {
      setState(() {
        _index++;
      });
      _markViewed();
      _progress.forward(from: 0);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prev() {
    if (_index > 0) {
      setState(() {
        _index--;
      });
      _progress.forward(from: 0);
    }
  }

  Future<void> _markViewed() async {
    final story = widget.stories[_index];
    if (!story.isViewed) {
      await StoryService.markViewed(story.id);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) {
          final w = MediaQuery.of(context).size.width;
          if (d.localPosition.dx < w / 2) {
            _prev();
          } else {
            _next();
          }
        },
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        child: Stack(
          children: [
            /// MEDIA
            Positioned.fill(
              child: Image.network(
                story.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.broken_image, color: Colors.white)),
              ),
            ),

            /// TOP GRADIENT
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ),

            /// PROGRESS BARS
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: List.generate(
                    widget.stories.length,
                    (i) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: LinearProgressIndicator(
                          value: i < _index
                              ? 1
                              : i == _index
                                  ? _progress.value
                                  : 0,
                          backgroundColor: Colors.white30,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// HEADER
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 40, 12, 0),
                child: Row(
                  children: [
                    Avatar(url: story.avatar, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        story.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

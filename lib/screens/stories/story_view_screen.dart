import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/story_service.dart';

class StoryViewScreen extends StatefulWidget {
  final List<dynamic> stories;
  final int index;

  const StoryViewScreen({
    super.key,
    required this.stories,
    required this.index,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  late int _current;
  double _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _current = widget.index;
    _start();
  }

  void _start() {
    StoryService.markViewed(widget.stories[_current]['id']);

    _timer?.cancel();
    _progress = 0;

    _timer = Timer.periodic(
      const Duration(milliseconds: 50),
      (t) {
        setState(() => _progress += 0.01);
        if (_progress >= 1) _next();
      },
    );
  }

  void _next() {
    if (_current < widget.stories.length - 1) {
      _current++;
      _start();
    } else {
      Navigator.pop(context);
    }
  }

  void _prev() {
    if (_current > 0) {
      _current--;
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.stories[_current];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (d) {
          final w = MediaQuery.of(context).size.width;
          d.localPosition.dx < w / 2 ? _prev() : _next();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                s['media'],
                fit: BoxFit.cover,
              ),
            ),

            // ===== PROGRESS =====
            Positioned(
              top: 40,
              left: 8,
              right: 8,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white30,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),

            // ===== USER =====
            Positioned(
              top: 60,
              left: 12,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(s['avatar']),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s['username'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/widgets/story_ring.dart

import 'package:flutter/material.dart';

class StoryRing extends StatelessWidget {
  final Widget child;
  final bool isViewed;
  final double size;
  final double borderWidth;

  const StoryRing({
    super.key,
    required this.child,
    required this.isViewed,
    this.size = 64,
    this.borderWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isViewed
            ? null
            : const LinearGradient(
                colors: [
                  Color(0xFFF58529), // orange
                  Color(0xFFDD2A7B), // pink
                  Color(0xFF8134AF), // purple
                  Color(0xFF515BD4), // blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isViewed ? Colors.grey.shade400 : null,
      ),
      child: ClipOval(
        child: child,
      ),
    );
  }
}

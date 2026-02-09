// lib/widgets/story_ring.dart
// =====================================================
// STORY RING – FINAL v5
// Instagram-like, gradient ring, build-safe
// =====================================================

import 'package:flutter/material.dart';

class StoryRing extends StatelessWidget {
  final Widget child;
  final bool isViewed;
  final double size;
  final double borderWidth;
  final VoidCallback? onTap;

  const StoryRing({
    super.key,
    required this.child,
    required this.isViewed,
    this.size = 64,
    this.borderWidth = 3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ringSize = size;
    final innerSize = size - borderWidth * 2;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: ringSize,
        height: ringSize,
        child: CustomPaint(
          painter: _StoryRingPainter(
            isViewed: isViewed,
            borderWidth: borderWidth,
          ),
          child: Center(
            child: SizedBox(
              width: innerSize,
              height: innerSize,
              child: ClipOval(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// CUSTOM PAINTER (SMOOTH GRADIENT)
// =====================================================

class _StoryRingPainter extends CustomPainter {
  final bool isViewed;
  final double borderWidth;

  _StoryRingPainter({
    required this.isViewed,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    if (isViewed) {
      paint.color = Colors.grey.shade400;
    } else {
      paint.shader = const SweepGradient(
        colors: [
          Color(0xFFF58529),
          Color(0xFFDD2A7B),
          Color(0xFF8134AF),
          Color(0xFF515BD4),
          Color(0xFFF58529),
        ],
      ).createShader(rect);
    }

    canvas.drawCircle(center, radius - borderWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant _StoryRingPainter oldDelegate) {
    return oldDelegate.isViewed != isViewed ||
        oldDelegate.borderWidth != borderWidth;
  }
}

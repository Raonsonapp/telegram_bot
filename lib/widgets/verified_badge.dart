// lib/widgets/verified_badge.dart
// =====================================================
// VERIFIED BADGE – FINAL v5
// Instagram-like, overlay-ready, build-safe
// =====================================================

import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? iconColor;

  const VerifiedBadge({
    super.key,
    this.size = 14,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        color ?? const Color(0xFF22C55E); // green verified
    final checkColor =
        iconColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: badgeColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        Icons.check_rounded,
        size: size * 0.75,
        color: checkColor,
      ),
    );
  }
}

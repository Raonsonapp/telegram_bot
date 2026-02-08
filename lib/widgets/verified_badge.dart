import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const VerifiedBadge({
    super.key,
    this.size = 16,
    this.backgroundColor = const Color(0xFF1ED760), // сабзи равшан
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black,
          width: size * 0.08,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: size * 0.25,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.check,
          size: size * 0.65,
          color: iconColor,
        ),
      ),
    );
  }
}

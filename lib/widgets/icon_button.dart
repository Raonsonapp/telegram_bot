import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final Color? activeColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.activeColor,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = active
        ? (activeColor ?? const Color(0xFFE53935)) // red like
        : Colors.white;

    return InkResponse(
      onTap: onTap,
      radius: size,
      splashColor: Colors.white24,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final Color activeColor;
  final bool isActive;
  final EdgeInsets padding;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 26,
    this.color = Colors.white,
    this.activeColor = Colors.red,
    this.isActive = false,
    this.padding = const EdgeInsets.all(6),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: padding,
        child: Icon(
          icon,
          size: size,
          color: isActive ? activeColor : color,
        ),
      ),
    );
  }
}

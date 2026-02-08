import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.size = 26,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (activeColor ?? AppColors.likeRed)
        : (inactiveColor ?? AppColors.icon);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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

// lib/widgets/icon_button.dart

import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double size;
  final EdgeInsets padding;
  final String? label;
  final bool vertical;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.size = 26,
    this.padding = const EdgeInsets.all(8),
    this.label,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: size,
      color: color ?? Colors.white,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: vertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  if (label != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      label!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  if (label != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      label!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

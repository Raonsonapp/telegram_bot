import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;
  final bool fullscreen;

  const AppLoading({
    super.key,
    this.message,
    this.size = 36,
    this.color = Colors.white,
    this.fullscreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final loader = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (fullscreen) {
      return Container(
        color: const Color(0xFF0F1424),
        alignment: Alignment.center,
        child: loader,
      );
    }

    return Center(child: loader);
  }
}

// lib/widgets/loading.dart

import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final String? text;
  final bool fullscreen;

  const AppLoading({
    super.key,
    this.text,
    this.fullscreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        if (text != null) ...[
          const SizedBox(height: 14),
          Text(
            text!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ],
    );

    if (!fullscreen) {
      return Center(child: content);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      body: Center(child: content),
    );
  }
}

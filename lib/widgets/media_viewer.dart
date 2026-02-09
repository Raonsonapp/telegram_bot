import 'package:flutter/material.dart';

class MediaViewer extends StatelessWidget {
  const MediaViewer({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        height: 220,
        color: Colors.white12,
        alignment: Alignment.center,
        child: const Icon(Icons.photo, size: 48, color: Colors.white54),
      );
    }
    return Image.network(
      url,
      height: 240,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

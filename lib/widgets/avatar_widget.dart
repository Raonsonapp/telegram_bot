import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({super.key, required this.imageUrl, this.size = 40});

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.white12,
      backgroundImage:
          hasImage ? NetworkImage(imageUrl) : null,
      child: hasImage
          ? null
          : Icon(Icons.person, size: size / 2, color: Colors.white70),
    );
  }
}

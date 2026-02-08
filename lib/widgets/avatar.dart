import 'package:flutter/material.dart';
import 'verified_badge.dart';

class Avatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final bool isVerified;
  final VoidCallback? onTap;

  const Avatar({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.isVerified = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade800,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: imageUrl.isEmpty
                  ? Container(
                      color: Colors.grey.shade900,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: size * 0.6,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: Colors.grey.shade900,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: size * 0.6,
                          ),
                        );
                      },
                    ),
            ),
          ),

          // VERIFIED BADGE
          if (isVerified)
            Positioned(
              bottom: -2,
              right: -2,
              child: VerifiedBadge(
                size: size * 0.35,
              ),
            ),
        ],
      ),
    );
  }
}

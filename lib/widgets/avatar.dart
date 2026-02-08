import 'package:flutter/material.dart';

import 'verified_badge.dart';

class Avatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool isVerified;
  final bool isOnline;
  final VoidCallback? onTap;

  const Avatar({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.isVerified = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _avatarImage(),
            if (isVerified) _verified(),
            if (isOnline) _onlineDot(),
          ],
        ),
      ),
    );
  }

  // ================= AVATAR IMAGE =================
  Widget _avatarImage() {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Colors.grey.shade800,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Icon(
                Icons.person,
                size: size * 0.6,
                color: Colors.white,
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Icon(
                    Icons.person,
                    size: size * 0.6,
                    color: Colors.white,
                  );
                },
              ),
      ),
    );
  }

  // ================= VERIFIED BADGE =================
  Widget _verified() {
    return Positioned(
      bottom: -2,
      right: -2,
      child: VerifiedBadge(size: size * 0.38),
    );
  }

  // ================= ONLINE DOT =================
  Widget _onlineDot() {
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        width: size * 0.28,
        height: size * 0.28,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
      ),
    );
  }
}

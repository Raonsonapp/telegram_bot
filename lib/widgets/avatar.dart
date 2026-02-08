import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'verified_badge.dart';

class Avatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool isVerified;
  final VoidCallback? onTap;
  final bool showBorder;

  const Avatar({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.isVerified = false,
    this.onTap,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _avatarCircle(),
          if (isVerified)
            Positioned(
              bottom: -2,
              right: -2,
              child: VerifiedBadge(size: size * 0.28),
            ),
        ],
      ),
    );
  }

  // ================= AVATAR CIRCLE =================
  Widget _avatarCircle() {
    return Container(
      width: size,
      height: size,
      padding: showBorder ? const EdgeInsets.all(2) : EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: showBorder
            ? const LinearGradient(
                colors: [
                  AppColors.storyPink,
                  AppColors.storyOrange,
                ],
              )
            : null,
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.darkGrey,
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
      ),
    );
  }

  // ================= PLACEHOLDER =================
  Widget _placeholder() {
    return Container(
      color: AppColors.darkGrey,
      child: Icon(
        Icons.person,
        color: AppColors.grey,
        size: size * 0.55,
      ),
    );
  }
}

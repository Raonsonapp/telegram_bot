import 'package:flutter/material.dart';
import '../theme/colors.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;

  const VerifiedBadge({
    super.key,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.verifiedGreen,
      ),
      child: Icon(
        Icons.check,
        size: size * 0.7,
        color: Colors.white,
      ),
    );
  }
}

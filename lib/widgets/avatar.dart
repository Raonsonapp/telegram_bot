// lib/widgets/avatar.dart
// =====================================================
// AVATAR WIDGET – FINAL v5
// Reusable, theme-aware, build-safe
// =====================================================

import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool hasBorder;
  final Color? borderColor;
  final VoidCallback? onTap;

  const Avatar({
    super.key,
    required this.imageUrl,
    this.size = 44,
    this.hasBorder = false,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        borderColor ?? Theme.of(context).colorScheme.primary;

    final avatar = Container(
      width: size,
      height: size,
      padding: hasBorder ? const EdgeInsets.all(2) : EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: hasBorder
            ? Border.all(color: effectiveBorderColor, width: 2)
            : null,
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );

    if (onTap == null) return avatar;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: avatar,
    );
  }

  // =====================================================
  // IMAGE / PLACEHOLDER
  // =====================================================

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _loading();
      },
    );
  }

  Widget _placeholder() {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey.shade300,
      child: Icon(
        Icons.person,
        size: size * 0.55,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _loading() {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey.shade200,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

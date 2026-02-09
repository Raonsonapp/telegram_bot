import 'package:flutter/material.dart';

import '../../models/reel.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/reel_actions.dart';

/// Overlay барои Reels (username, caption, music + actions)
/// Version: v5 FULL
class ReelOverlay extends StatelessWidget {
  final Reel reel;
  final VoidCallback? onProfileTap;

  const ReelOverlay({
    super.key,
    required this.reel,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // ================= LEFT INFO =================
          Positioned(
            left: 12,
            bottom: 24,
            right: 90,
            child: _leftInfo(context),
          ),

          // ================= RIGHT ACTIONS =================
          Positioned(
            right: 12,
            bottom: 24,
            child: ReelActions(reel: reel),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // LEFT INFO (User + caption + music)
  // =====================================================
  Widget _leftInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ===== USER ROW =====
        GestureDetector(
          onTap: onProfileTap,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: reel.userAvatar.isNotEmpty
                    ? NetworkImage(reel.userAvatar)
                    : null,
                child: reel.userAvatar.isEmpty
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                reel.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              if (reel.isVerified) const VerifiedBadge(),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ===== CAPTION =====
        if (reel.caption.isNotEmpty)
          Text(
            reel.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),

        const SizedBox(height: 6),

        // ===== MUSIC =====
        if (reel.musicTitle.isNotEmpty)
          Row(
            children: [
              const Icon(
                Icons.music_note,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  reel.musicTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

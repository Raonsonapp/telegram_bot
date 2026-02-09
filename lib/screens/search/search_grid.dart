import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../reels/reels_screen.dart';

/// SearchGrid
/// ----------------------------------------------
/// Universal grid for Search results:
/// - Posts
/// - Reels
///
/// Used in SearchTabs
/// Version: v5 FULL
class SearchGrid extends StatelessWidget {
  final List<Post> items;
  final bool isReels;

  const SearchGrid({
    super.key,
    required this.items,
    this.isReels = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final post = items[index];

        return GestureDetector(
          onTap: () {
            if (isReels || post.isReel) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReelsScreen(
                    initialReelId: post.id,
                  ),
                ),
              );
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              Image.network(
                post.mediaThumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade900,
                ),
              ),

              // Reel icon
              if (post.isReel)
                const Positioned(
                  bottom: 6,
                  right: 6,
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

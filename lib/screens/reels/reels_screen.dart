import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../services/post_service.dart';
import '../../core/session.dart';
import 'reel_player.dart';
import 'reel_actions.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  List<dynamic> _reels = [];
  bool _loading = true;
  String _me = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _me = await Session.username() ?? '';
    await _loadReels();
  }

  Future<void> _loadReels() async {
    try {
      final data = await PostService.getReels();
      setState(() {
        _reels = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_reels.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No reels yet',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        itemBuilder: (context, index) {
          final reel = _reels[index];

          return Stack(
            fit: StackFit.expand,
            children: [
              // ===== VIDEO PLAYER =====
              ReelPlayer(
                videoUrl: reel['media_url'],
                autoPlay: index == 0,
              ),

              // ===== GRADIENT (BOTTOM) =====
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 250,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ===== LEFT INFO =====
              Positioned(
                left: 16,
                bottom: 40,
                right: 80,
                child: _reelInfo(reel),
              ),

              // ===== RIGHT ACTIONS =====
              Positioned(
                right: 12,
                bottom: 80,
                child: ReelActions(
                  postId: reel['id'],
                  likesCount: reel['likes'] ?? 0,
                  commentsCount: reel['comments'] ?? 0,
                  isLiked: reel['is_liked'] ?? false,
                  isSaved: reel['is_saved'] ?? false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= INFO (USERNAME + CAPTION) =================
  Widget _reelInfo(dynamic reel) {
    final String username = reel['username'] ?? '';
    final String caption = reel['caption'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            if (reel['is_verified'] == true)
              const Icon(
                Icons.verified,
                size: 16,
                color: Colors.green,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (caption.isNotEmpty)
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/reel.dart';
import '../../services/reel_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/reel_actions.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  final List<VideoPlayerController> _controllers = [];

  bool _loading = true;
  List<Reel> _reels = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  Future<void> _loadReels() async {
    try {
      final data = await ReelService.getFeed();

      // clear old controllers
      for (final c in _controllers) {
        c.dispose();
      }
      _controllers.clear();

      _reels = data;

      for (final r in _reels) {
        final c =
            VideoPlayerController.networkUrl(Uri.parse(r.videoUrl));
        await c.initialize();
        c.setLooping(true);
        _controllers.add(c);
      }

      if (_controllers.isNotEmpty) {
        _controllers.first.play();
      }

      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_controllers.isEmpty) return;

    _controllers[_currentIndex].pause();
    _currentIndex = index;
    _controllers[_currentIndex].play();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: AppLoading()),
      );
    }

    if (_reels.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: EmptyState(text: 'No reels yet'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return _reelItem(_reels[index], _controllers[index]);
        },
      ),
    );
  }

  // ================= REEL ITEM =================
  Widget _reelItem(Reel reel, VideoPlayerController controller) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ===== VIDEO =====
        GestureDetector(
          onTap: () {
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
            setState(() {});
          },
          child: VideoPlayer(controller),
        ),

        // ===== GRADIENT =====
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: [
                Colors.black87,
                Colors.transparent,
              ],
            ),
          ),
        ),

        // ===== LEFT INFO =====
        Positioned(
          left: 12,
          bottom: 24,
          right: 80,
          child: _reelInfo(reel),
        ),

        // ===== ACTIONS =====
        Positioned(
          right: 8,
          bottom: 24,
          child: ReelActions(
            reel: reel,
            onChanged: _loadReels,
          ),
        ),
      ],
    );
  }

  // ================= INFO =================
  Widget _reelInfo(Reel reel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Avatar(
              imageUrl: reel.user.avatarUrl,
              size: 36,
            ),
            const SizedBox(width: 8),
            Text(
              reel.user.username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (reel.user.isVerified) ...[
              const SizedBox(width: 4),
              const VerifiedBadge(),
            ],
          ],
        ),
        if (reel.caption != null && reel.caption!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            reel.caption!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ],
    );
  }
}

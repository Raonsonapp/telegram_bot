import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../services/post_service.dart';
import '../comments/comments_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _page = PageController();
  List<dynamic> _reels = [];
  bool _loading = true;
  int _index = 0;

  VideoPlayerController? _player;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await PostService.getReels();
    setState(() {
      _reels = data;
      _loading = false;
    });
    _play(0);
  }

  Future<void> _play(int i) async {
    _player?.dispose();

    final url = _reels[i]['video'];
    _player = VideoPlayerController.networkUrl(Uri.parse(url));
    await _player!.initialize();
    _player!
      ..setLooping(true)
      ..play();

    setState(() {});
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
      controller: _page,
      scrollDirection: Axis.vertical,
      itemCount: _reels.length,
      onPageChanged: (i) {
        _index = i;
        _play(i);
      },
      itemBuilder: (_, i) => _reel(_reels[i]),
    );
  }

  Widget _reel(dynamic r) {
    final int id = r['id'];
    final String user = r['username'];
    final String caption = r['caption'] ?? '';
    final int likes = r['likes'] ?? 0;
    final bool liked = r['liked'] ?? false;
    final bool saved = r['saved'] ?? false;

    return Stack(
      children: [
        // ===== VIDEO =====
        Positioned.fill(
          child: _player != null && _player!.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _player!.value.size.width,
                    height: _player!.value.size.height,
                    child: VideoPlayer(_player!),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),

        // ===== RIGHT ACTIONS =====
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              _icon(
                icon: liked ? Icons.favorite : Icons.favorite_border,
                label: '$likes',
                onTap: () async {
                  liked
                      ? await PostService.unlike(id)
                      : await PostService.like(id);
                  _load();
                },
              ),
              const SizedBox(height: 18),
              _icon(
                icon: Icons.mode_comment_outlined,
                label: 'Comment',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(postId: id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              _icon(
                icon: saved ? Icons.bookmark : Icons.bookmark_border,
                label: 'Save',
                onTap: () async {
                  saved
                      ? await PostService.unsave(id)
                      : await PostService.save(id);
                  _load();
                },
              ),
            ],
          ),
        ),

        // ===== BOTTOM INFO =====
        Positioned(
          left: 12,
          bottom: 40,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@$user',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                caption,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _icon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: 30),
          onPressed: onTap,
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

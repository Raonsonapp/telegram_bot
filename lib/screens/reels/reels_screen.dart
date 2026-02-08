import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../services/reel_service.dart';
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
  final Map<int, VideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ReelService.getReels();
    setState(() {
      _reels = data;
      _loading = false;
    });
    _initController(0);
  }

  void _initController(int index) {
    if (_controllers.containsKey(index)) return;

    final c = VideoPlayerController.network(_reels[index]['video']);
    _controllers[index] = c;
    c.initialize().then((_) {
      c.setLooping(true);
      c.play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
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
        _controllers.forEach((k, v) => v.pause());
        _initController(i);
        _controllers[i]?.play();
      },
      itemBuilder: (_, i) => _item(_reels[i], i),
    );
  }

  Widget _item(dynamic reel, int index) {
    final c = _controllers[index];

    return Stack(
      children: [
        if (c != null && c.value.isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            ),
          ),

        // RIGHT ACTIONS
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              _icon(
                Icons.favorite,
                reel['liked'] ? Colors.red : Colors.white,
                () async {
                  reel['liked']
                      ? await ReelService.unlike(reel['id'])
                      : await ReelService.like(reel['id']);
                  setState(() => reel['liked'] = !reel['liked']);
                },
                label: reel['likes'].toString(),
              ),
              _icon(
                Icons.mode_comment,
                Colors.white,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(postId: reel['id']),
                    ),
                  );
                },
                label: reel['comments'].toString(),
              ),
              _icon(
                Icons.send,
                Colors.white,
                () {},
              ),
              _icon(
                Icons.bookmark,
                Colors.white,
                () async {
                  await ReelService.save(reel['id']);
                },
              ),
            ],
          ),
        ),

        // BOTTOM USER
        Positioned(
          left: 12,
          bottom: 40,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${reel['username']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                reel['caption'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _icon(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          IconButton(
            icon: Icon(icon, color: color, size: 30),
            onPressed: onTap,
          ),
          if (label != null)
            Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

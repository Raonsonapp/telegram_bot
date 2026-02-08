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
  List<dynamic> _reels = [];
  bool _loading = true;

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
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        itemBuilder: (_, i) => ReelItem(reel: _reels[i]),
      ),
    );
  }
}

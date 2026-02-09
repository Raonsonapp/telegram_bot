import 'package:flutter/material.dart';

import '../../models/story.dart';
import '../../services/story_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/story_ring.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';

class StoryBar extends StatefulWidget {
  const StoryBar({
    super.key,
    required this.me,
  });

  final String me;

  @override
  State<StoryBar> createState() => _StoryBarState();
}

class _StoryBarState extends State<StoryBar> {
  bool _loading = true;
  List<Story> _stories = [];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    try {
      final data = await StoryService.getStories();
      if (!mounted) return;
      setState(() {
        _stories = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 96,
        child: Loading(),
      );
    }

    if (_stories.isEmpty) {
      return const SizedBox(
        height: 96,
        child: EmptyState(
          icon: Icons.auto_stories,
          text: 'No stories yet',
        ),
      );
    }

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _item(_stories[i]),
      ),
    );
  }

  Widget _item(Story story) {
    final isMe = story.username == widget.me;

    return GestureDetector(
      onTap: () => _openStory(story),
      child: Column(
        children: [
          StoryRing(
            viewed: story.isViewed,
            isMe: isMe,
            child: Avatar(
              url: story.avatar,
              size: 64,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              isMe ? 'Your story' : story.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openStory(Story story) async {
    Navigator.pushNamed(
      context,
      '/story',
      arguments: story,
    );

    if (!story.isViewed) {
      await StoryService.markViewed(story.id);
      _loadStories();
    }
  }
}

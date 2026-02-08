import 'package:flutter/material.dart';
import '../../services/story_service.dart';
import '../stories/story_view_screen.dart';

class StoryBar extends StatefulWidget {
  const StoryBar({super.key});

  @override
  State<StoryBar> createState() => _StoryBarState();
}

class _StoryBarState extends State<StoryBar> {
  List<dynamic> _stories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await StoryService.getStories();
    setState(() => _stories = data);
  }

  @override
  Widget build(BuildContext context) {
    if (_stories.isEmpty) return const SizedBox();

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stories.length,
        itemBuilder: (_, i) {
          final s = _stories[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryViewScreen(
                    stories: _stories,
                    index: i,
                  ),
                ),
              );
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(s['avatar']),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s['username'],
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

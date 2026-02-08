import 'package:flutter/material.dart';
import '../../services/story_service.dart';
import '../story/story_view_screen.dart';

class StoryBar extends StatefulWidget {
  const StoryBar({super.key});

  @override
  State<StoryBar> createState() => _StoryBarState();
}

class _StoryBarState extends State<StoryBar> {
  List<dynamic> _stories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await StoryService.getStories();
    setState(() {
      _stories = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stories.length,
        itemBuilder: (_, i) {
          final s = _stories[i];
          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryViewScreen(story: s),
                ),
              );
              await StoryService.markViewed(s['id']);
              _load();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: s['is_viewed'] == true
                            ? Colors.grey
                            : Colors.pink,
                        width: 2,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          NetworkImage('https://placehold.co/100x100'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s['username'] ?? '',
                    style: const TextStyle(fontSize: 12),
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

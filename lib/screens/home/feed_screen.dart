import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../services/post_service.dart';
import 'story_bar.dart';
import 'post_item.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _loading = true;
  List<dynamic> _posts = [];
  String _me = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _me = await Session.getToken() ?? '';
    await _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final data = await PostService.getFeedPosts();
      setState(() {
        _posts = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Raonson',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.smart_toy), // Jarvis
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: ListView(
                children: [
                  const StoryBar(),
                  const Divider(height: 1),
                  ..._posts.map(
                    (p) => PostItem(
                      post: p,
                      me: _me,
                      onRefresh: _loadFeed,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

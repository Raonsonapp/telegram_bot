import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../services/search_service.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import 'search_grid.dart';

/// HashtagScreen
/// --------------------------------------------
/// Shows posts for a specific hashtag
/// Example: #raonson
///
/// Version: v5 FULL
class HashtagScreen extends StatefulWidget {
  final String hashtag;

  const HashtagScreen({
    super.key,
    required this.hashtag,
  });

  @override
  State<HashtagScreen> createState() => _HashtagScreenState();
}

class _HashtagScreenState extends State<HashtagScreen> {
  bool _loading = true;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await SearchService.searchHashtag(widget.hashtag);
      setState(() {
        _posts = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '#${widget.hashtag}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Loading()
          : _posts.isEmpty
              ? const EmptyState(
                  icon: Icons.tag,
                  title: 'No posts yet',
                  subtitle: 'Posts with this hashtag will appear here',
                )
              : SearchGrid(items: _posts),
    );
  }
}

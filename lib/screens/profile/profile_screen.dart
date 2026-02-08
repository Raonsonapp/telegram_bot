import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../services/follow_service.dart';
import '../../services/post_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? username; // null => my profile
  const ProfileScreen({super.key, this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  bool _following = false;

  String _me = '';
  String _user = '';
  String _bio = '';
  bool _verified = false;

  int _postsCount = 0;
  int _followers = 0;
  int _followingCount = 0;

  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _me = await Session.username() ?? '';
    _user = widget.username ?? _me;
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final counts = await FollowService.getCounts(_user);
      final posts = await PostService.getByUser(_user);

      setState(() {
        _bio = counts['bio'] ?? '';
        _verified = counts['verified'] == true;
        _followers = counts['followers'];
        _followingCount = counts['following'];
        _following = counts['is_following'] == true;
        _posts = posts;
        _postsCount = posts.length;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_following) {
      await FollowService.unfollow(_user);
    } else {
      await FollowService.follow(_user);
    }
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(_user),
            if (_verified)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.verified, color: Colors.green, size: 18),
              ),
          ],
        ),
      ),
      body: ListView(
        children: [
          _header(),
          _bioSection(),
          const Divider(),
          _grid(),
        ],
      ),
    );
  }

  // ===== HEADER =====
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 36,
            child: Icon(Icons.person, size: 36),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat('Posts', _postsCount),
                _stat('Followers', _followers),
                _stat('Following', _followingCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text('$value',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }

  // ===== BIO + FOLLOW =====
  Widget _bioSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_bio),
            ),
          if (_user != _me)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _following ? Colors.grey : Colors.green,
                ),
                onPressed: _toggleFollow,
                child: Text(_following ? 'Following' : 'Follow'),
              ),
            ),
        ],
      ),
    );
  }

  // ===== GRID =====
  Widget _grid() {
    if (_posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No posts yet')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _posts.length,
      itemBuilder: (_, i) {
        final p = _posts[i];
        return Image.network(
          p['image_url'],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../services/post_service.dart';
import '../../services/follow_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? username; // агар null → профили худи ман

  const ProfileScreen({super.key, this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loading = true;
  bool _isMe = true;
  bool _isFollowing = false;

  String _me = '';
  String _username = '';
  bool _verified = false;

  int _followers = 0;
  int _following = 0;

  List<dynamic> _posts = [];
  List<dynamic> _reels = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _init();
  }

  Future<void> _init() async {
    _me = await Session.username() ?? '';
    _username = widget.username ?? _me;
    _isMe = _username == _me;

    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await FollowService.getProfile(_username);

      _followers = data['followers'];
      _following = data['following'];
      _verified = data['verified'];
      _isFollowing = data['is_following'] ?? false;

      _posts = await PostService.getByUser(_username);
      _reels = await PostService.getReelsByUser(_username);

      setState(() => _loading = false);
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _header(),
                _actions(),
                _tabs(),
                Expanded(child: _tabView()),
              ],
            ),
    );
  }

  // ================= APP BAR =================
  AppBar _appBar() {
    return AppBar(
      title: Row(
        children: [
          Text(_username),
          if (_verified)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.verified, color: Colors.green, size: 18),
            ),
        ],
      ),
      actions: _isMe
          ? [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await Session.clearSession();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              )
            ]
          : [],
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _countItem(_posts.length, 'Posts'),
                _countItem(_followers, 'Followers'),
                _countItem(_following, 'Following'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countItem(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label),
      ],
    );
  }

  // ================= ACTIONS =================
  Widget _actions() {
    if (_isMe) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: OutlinedButton(
          onPressed: () {},
          child: const Text('Edit profile'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () async {
          _isFollowing
              ? await FollowService.unfollow(_username)
              : await FollowService.follow(_username);
          _loadProfile();
        },
        child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
      ),
    );
  }

  // ================= TABS =================
  Widget _tabs() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Icons.grid_on)),
        Tab(icon: Icon(Icons.video_library)),
      ],
    );
  }

  Widget _tabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _grid(_posts),
        _grid(_reels),
      ],
    );
  }

  Widget _grid(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No content'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final url = items[i]['media_url'] ?? '';
        return Container(
          color: Colors.black12,
          child: url.isEmpty
              ? const Icon(Icons.image)
              : Image.network(url, fit: BoxFit.cover),
        );
      },
    );
  }
}

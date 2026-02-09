import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/post.dart';
import '../../services/user_service.dart';
import '../../services/post_service.dart';
import '../../services/follow_service.dart';
import '../../core/session.dart';
import '../../widgets/avatar.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/empty_state.dart';
import '../home/post_card.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? username; // null = me

  const ProfileScreen({super.key, this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  bool _isMe = false;
  bool _isFollowing = false;

  User? _user;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ================= LOAD =================
  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final me = await Session.getUsername();
      final username = widget.username ?? me;

      if (username == null) {
        throw Exception('No username');
      }

      _isMe = username == me;

      final user = await UserService.getProfile(username);
      final posts = await PostService.getByUser(username);

      bool following = false;
      if (!_isMe) {
        following = await FollowService.isFollowing(username);
      }

      setState(() {
        _user = user;
        _posts = posts;
        _isFollowing = following;
      });
    } catch (_) {
      // silent fail
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= FOLLOW =================
  Future<void> _toggleFollow() async {
    if (_user == null) return;

    if (_isFollowing) {
      await FollowService.unfollowUser(_user!.username);
    } else {
      await FollowService.followUser(_user!.username);
    }

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_user!.username),
        actions: [
          if (_isMe)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            _header(),
            _stats(),
            _actionButton(),
            const Divider(height: 24),
            _postsGrid(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    final u = _user!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Avatar(imageUrl: u.avatar, size: 80),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      u.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (u.isVerified) const SizedBox(width: 6),
                    if (u.isVerified) const VerifiedBadge(),
                  ],
                ),
                if (u.bio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(u.bio),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _stats() {
    final u = _user!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Posts', _posts.length),
          _stat('Followers', u.followersCount),
          _stat('Following', u.followingCount),
        ],
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ================= ACTION =================
  Widget _actionButton() {
    if (_isMe) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(user: _user!),
              ),
            ).then((_) => _load());
          },
          child: const Text('Edit profile'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _toggleFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isFollowing ? Colors.grey.shade300 : null,
        ),
        child: Text(_isFollowing ? 'Following' : 'Follow'),
      ),
    );
  }

  // ================= POSTS =================
  Widget _postsGrid() {
    if (_posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: EmptyState(
          title: 'No posts yet',
          icon: Icons.photo,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (_, i) {
        return PostCard(
          post: _posts[i],
          me: _user!.username,
          onDeleted: _load,
        );
      },
    );
  }
}

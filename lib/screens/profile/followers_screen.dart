import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/follow_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';

class FollowersScreen extends StatefulWidget {
  final String username;

  const FollowersScreen({
    super.key,
    required this.username,
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  bool _loading = true;
  List<User> _followers = [];

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    setState(() => _loading = true);

    try {
      final data = await FollowService.getFollowers(widget.username);
      setState(() {
        _followers = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleFollow(User user) async {
    try {
      if (user.isFollowing) {
        await FollowService.unfollow(user.username);
      } else {
        await FollowService.follow(user.username);
      }

      setState(() {
        user.isFollowing = !user.isFollowing;
      });
    } catch (_) {}
  }

  Widget _userTile(User user) {
    return ListTile(
      leading: Avatar(
        url: user.avatar,
        size: 44,
      ),
      title: Row(
        children: [
          Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          if (user.isVerified) const VerifiedBadge(),
        ],
      ),
      subtitle: user.bio.isNotEmpty ? Text(user.bio) : null,
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              user.isFollowing ? Colors.grey.shade800 : Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => _toggleFollow(user),
        child: Text(user.isFollowing ? 'Following' : 'Follow'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followers'),
      ),
      body: _loading
          ? const Loading()
          : _followers.isEmpty
              ? const EmptyState(
                  icon: Icons.people_outline,
                  title: 'No followers yet',
                  subtitle: 'When someone follows you, they will appear here',
                )
              : RefreshIndicator(
                  onRefresh: _loadFollowers,
                  child: ListView.separated(
                    itemCount: _followers.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (_, i) => _userTile(_followers[i]),
                  ),
                ),
    );
  }
}

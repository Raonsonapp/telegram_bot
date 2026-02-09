import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/follow_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';

class FollowingScreen extends StatefulWidget {
  final String username;

  const FollowingScreen({
    super.key,
    required this.username,
  });

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  bool _loading = true;
  List<User> _following = [];

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    setState(() => _loading = true);

    try {
      final data = await FollowService.getFollowing(widget.username);
      setState(() {
        _following = data;
        _loading = false;
      });
    } catch (_) {
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
        title: const Text('Following'),
      ),
      body: _loading
          ? const Loading()
          : _following.isEmpty
              ? const EmptyState(
                  icon: Icons.person_add_alt_outlined,
                  title: 'Not following anyone',
                  subtitle:
                      'Accounts you follow will appear here',
                )
              : RefreshIndicator(
                  onRefresh: _loadFollowing,
                  child: ListView.separated(
                    itemCount: _following.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (_, i) => _userTile(_following[i]),
                  ),
                ),
    );
  }
}

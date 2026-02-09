import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/follow_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';

enum FollowType { followers, following }

class FollowListScreen extends StatefulWidget {
  final String username;
  final FollowType type;

  const FollowListScreen({
    super.key,
    required this.username,
    required this.type,
  });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  bool _loading = true;
  List<User> _users = [];
  List<User> _filtered = [];
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_filter);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final data = widget.type == FollowType.followers
          ? await FollowService.getFollowers(widget.username)
          : await FollowService.getFollowing(widget.username);

      setState(() {
        _users = data;
        _filtered = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = _users
          .where((u) => u.username.toLowerCase().contains(q))
          .toList();
    });
  }

  Future<void> _toggleFollow(User user) async {
    try {
      if (user.isFollowing) {
        await FollowService.unfollowUser(user.username);
      } else {
        await FollowService.followUser(user.username);
      }

      setState(() {
        user.isFollowing = !user.isFollowing;
      });
    } catch (_) {}
  }

  Widget _item(User user) {
    return ListTile(
      leading: Avatar(url: user.avatar),
      title: Row(
        children: [
          Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (user.isVerified) ...[
            const SizedBox(width: 4),
            const VerifiedBadge(),
          ],
        ],
      ),
      subtitle: user.bio.isNotEmpty ? Text(user.bio) : null,
      trailing: ElevatedButton(
        onPressed: () => _toggleFollow(user),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              user.isFollowing ? Colors.grey.shade300 : Colors.blue,
          foregroundColor:
              user.isFollowing ? Colors.black : Colors.white,
          minimumSize: const Size(90, 34),
        ),
        child: Text(user.isFollowing ? 'Following' : 'Follow'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.type == FollowType.followers ? 'Followers' : 'Following';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _loading
          ? const Loading()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          title: 'No users',
                          subtitle: '',
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) =>
                                _item(_filtered[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

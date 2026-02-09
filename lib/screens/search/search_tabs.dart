import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/post.dart';
import '../../services/search_service.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import '../profile/profile_screen.dart';
import '../reels/reels_screen.dart';

/// SearchTabs
/// --------------------------------------------------
/// Tabs for Search results:
/// - Users
/// - Posts
/// - Reels
///
/// Version: v5 FULL
class SearchTabs extends StatefulWidget {
  final String query;

  const SearchTabs({
    super.key,
    required this.query,
  });

  @override
  State<SearchTabs> createState() => _SearchTabsState();
}

class _SearchTabsState extends State<SearchTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loading = true;
  List<User> _users = [];
  List<Post> _posts = [];
  List<Post> _reels = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void didUpdateWidget(covariant SearchTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _load();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =========================
  // LOAD DATA
  // =========================
  Future<void> _load() async {
    if (widget.query.trim().isEmpty) {
      setState(() {
        _users = [];
        _posts = [];
        _reels = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await SearchService.search(widget.query);
      setState(() {
        _users = result.users;
        _posts = result.posts.where((p) => !p.isReel).toList();
        _reels = result.posts.where((p) => p.isReel).toList();
      });
    } catch (_) {
      setState(() {
        _users = [];
        _posts = [];
        _reels = [];
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tabBar(),
        Expanded(
          child: _loading
              ? const Center(child: Loading())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _usersTab(),
                    _postsTab(),
                    _reelsTab(),
                  ],
                ),
        ),
      ],
    );
  }

  // =========================
  // TAB BAR
  // =========================
  Widget _tabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Colors.grey,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: 'Users'),
        Tab(text: 'Posts'),
        Tab(text: 'Reels'),
      ],
    );
  }

  // =========================
  // USERS TAB
  // =========================
  Widget _usersTab() {
    if (_users.isEmpty) {
      return const EmptyState(
        icon: Icons.person_off,
        title: 'No users',
        subtitle: 'No users found',
      );
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
            child: user.avatar.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(user.username),
          subtitle: Text('${user.followersCount} followers'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfileScreen(username: user.username),
              ),
            );
          },
        );
      },
    );
  }

  // =========================
  // POSTS TAB
  // =========================
  Widget _postsTab() {
    if (_posts.isEmpty) {
      return const EmptyState(
        icon: Icons.image_not_supported,
        title: 'No posts',
        subtitle: 'No posts found',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];

        return Image.network(
          post.mediaThumbnail,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: Colors.grey.shade800),
        );
      },
    );
  }

  // =========================
  // REELS TAB
  // =========================
  Widget _reelsTab() {
    if (_reels.isEmpty) {
      return const EmptyState(
        icon: Icons.movie_creation_outlined,
        title: 'No reels',
        subtitle: 'No reels found',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: _reels.length,
      itemBuilder: (context, index) {
        final reel = _reels[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ReelsScreen(initialReelId: reel.id),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                reel.mediaThumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey.shade800),
              ),
              const Positioned(
                bottom: 6,
                right: 6,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/post.dart';
import '../../services/search_service.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import '../profile/profile_screen.dart';
import '../reels/reels_screen.dart';

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

  // ================= LOAD =================
  Future<void> _load() async {
    final q = widget.query.trim();
    if (q.isEmpty) {
      if (!mounted) return;
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
      final res = await SearchService.search(q);

      if (!mounted) return;

      _users = (res['users'] as List? ?? [])
          .map((e) => User.fromJson(e))
          .toList();

      _posts = (res['posts'] as List? ?? [])
          .map((e) => Post.fromJson(e))
          .toList();

      _reels = (res['reels'] as List? ?? [])
          .map((e) => Post.fromJson(e))
          .toList();
    } catch (_) {
      if (!mounted) return;
      _users = [];
      _posts = [];
      _reels = [];
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tabBar(),
        Expanded(
          child: _loading
              ? const Center(child: AppLoading(fullscreen: false))
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

  // ================= TAB BAR =================
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

  // ================= USERS =================
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
      itemBuilder: (context, i) {
        final u = _users[i];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                u.avatarUrl != null ? NetworkImage(u.avatarUrl!) : null,
            child: u.avatarUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(u.username),
          subtitle: Text('${u.followersCount} followers'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(username: u.username),
              ),
            );
          },
        );
      },
    );
  }

  // ================= POSTS =================
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
      itemBuilder: (_, i) {
        final p = _posts[i];

        return Image.network(
          p.mediaUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: Colors.grey.shade800),
        );
      },
    );
  }

  // ================= REELS =================
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
      itemBuilder: (_, i) {
        final r = _reels[i];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReelsScreen()),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                r.mediaUrl,
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

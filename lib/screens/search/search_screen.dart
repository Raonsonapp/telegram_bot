import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../models/user.dart';
import '../../services/search_service.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import '../profile/profile_screen.dart';
import '../reels/reels_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _loading = false;
  List<User> _users = [];
  List<Post> _posts = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================
  // SEARCH
  // =========================
  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _users = [];
        _posts = [];
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await SearchService.search(query);

      if (!mounted) return;

      _users = (res['users'] as List)
          .map<User>((e) => User.fromJson(e))
          .toList();

      _posts = (res['posts'] as List)
          .map<Post>((e) => Post.fromJson(e))
          .toList();
    } catch (_) {
      if (!mounted) return;
      _users = [];
      _posts = [];
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _loading
          ? const Center(child: AppLoading(fullscreen: false))
          : _controller.text.isEmpty
              ? _exploreGrid()
              : _searchResult(),
    );
  }

  // =========================
  // APP BAR
  // =========================
  PreferredSizeWidget _appBar() {
    return AppBar(
      title: TextField(
        controller: _controller,
        autofocus: false,
        onChanged: _search,
        decoration: InputDecoration(
          hintText: 'Search',
          filled: true,
          fillColor: Colors.grey.shade900,
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // =========================
  // SEARCH RESULT
  // =========================
  Widget _searchResult() {
    if (_users.isEmpty && _posts.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Nothing found',
        subtitle: 'Try another keyword',
      );
    }

    return ListView(
      children: [
        // ===== USERS =====
        if (_users.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Users',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ..._users.map(_userTile),

        // ===== POSTS =====
        if (_posts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Posts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        _postsGrid(),
      ],
    );
  }

  // =========================
  // USER TILE
  // =========================
  Widget _userTile(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null || user.avatarUrl!.isEmpty
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(user.username),
      subtitle: Text('${user.followersCount} followers'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(username: user.username),
          ),
        );
      },
    );
  }

  // =========================
  // EXPLORE GRID
  // =========================
  Widget _exploreGrid() {
    if (_posts.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.grid_on,
          title: 'Explore',
          subtitle: 'Discover new posts',
        ),
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

        return GestureDetector(
          onTap: () {
            if (post.isVideo) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReelsScreen(initialReelId: post.id),
                ),
              );
            }
          },
          child: Image.network(
            post.mediaUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.grey.shade800),
          ),
        );
      },
    );
  }

  // =========================
  // POSTS GRID (search)
  // =========================
  Widget _postsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];

        return GestureDetector(
          onTap: () {
            if (post.isVideo) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReelsScreen(initialReelId: post.id),
                ),
              );
            }
          },
          child: Image.network(
            post.mediaUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.grey.shade800),
          ),
        );
      },
    );
  }
}

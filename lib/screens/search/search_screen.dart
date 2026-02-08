import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/search_service.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  final _controller = TextEditingController();
  Timer? _debounce;

  bool _loading = false;
  List<dynamic> _users = [];
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _tab.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _loading = true);
      try {
        final u = await SearchService.users(q);
        final p = await SearchService.posts(q);
        setState(() {
          _users = u;
          _posts = p;
          _loading = false;
        });
      } catch (_) {
        setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
          _searchField(),
          TabBar(
            controller: _tab,
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Posts'),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tab,
                    children: [
                      _usersTab(),
                      _postsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ================= APP BAR =================
  AppBar _appBar() {
    return AppBar(
      title: const Text('Search'),
    );
  }

  // ================= SEARCH FIELD =================
  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _controller,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= USERS TAB =================
  Widget _usersTab() {
    if (_users.isEmpty) {
      return const Center(child: Text('No users'));
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (_, i) {
        final u = _users[i];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Row(
            children: [
              Text(u['username']),
              if (u['verified'] == true)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.verified, size: 16, color: Colors.green),
                ),
            ],
          ),
          subtitle: Text('${u['followers']} followers'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(username: u['username']),
              ),
            );
          },
        );
      },
    );
  }

  // ================= POSTS TAB =================
  Widget _postsTab() {
    if (_posts.isEmpty) {
      return const Center(child: Text('No posts'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _posts.length,
      itemBuilder: (_, i) {
        final p = _posts[i];
        final url = p['media_url'] ?? '';
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

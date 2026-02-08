import 'package:flutter/material.dart';
import '../../services/search_service.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  List<dynamic> _users = [];
  List<dynamic> _posts = [];

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;

    setState(() => _loading = true);

    final data = await SearchService.search(q);

    setState(() {
      _users = data['users'] ?? [];
      _posts = data['posts'] ?? [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (_users.isNotEmpty) _usersSection(),
                if (_posts.isNotEmpty) _postsGrid(),
              ],
            ),
    );
  }

  // ================= USERS =================
  Widget _usersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Users',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ..._users.map((u) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Row(
              children: [
                Text(u['username']),
                if (u['verified'] == true)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.verified,
                        size: 16, color: Colors.green),
                  ),
              ],
            ),
            subtitle: Text(u['bio'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProfileScreen(username: u['username']),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  // ================= POSTS =================
  Widget _postsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      padding: const EdgeInsets.all(2),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (_, i) {
        return Image.network(
          _posts[i]['image_url'],
          fit: BoxFit.cover,
        );
      },
    );
  }
}

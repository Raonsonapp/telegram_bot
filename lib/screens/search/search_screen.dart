import 'package:flutter/material.dart';
import '../../services/search_service.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    final data = await SearchService.search(q);
    setState(() {
      _results = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          onChanged: _search,
          decoration: InputDecoration(
            hintText: 'Search',
            filled: true,
            fillColor: Colors.grey[900],
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? _empty()
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (_, i) => _item(_results[i]),
                ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Text(
        'Search users or posts',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  Widget _item(dynamic r) {
    if (r['type'] == 'user') {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(r['avatar']),
        ),
        title: Text(r['username']),
        subtitle: Text('${r['followers']} followers'),
        trailing: r['verified'] == true
            ? const Icon(Icons.verified, color: Colors.green)
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileScreen(username: r['username']),
            ),
          );
        },
      );
    }

    // POST
    return ListTile(
      leading: Image.network(
        r['media'],
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(r['caption'] ?? ''),
      subtitle: Text(r['username']),
    );
  }
}

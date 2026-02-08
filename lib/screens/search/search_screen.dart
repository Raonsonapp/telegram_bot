import 'package:flutter/material.dart';
import '../../services/search_service.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _c = TextEditingController();
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _loadExplore();
  }

  Future<void> _loadExplore() async {
    setState(() => _loading = true);
    final data = await SearchService.explore();
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _search(String q) async {
    if (q.isEmpty) {
      _loadExplore();
      return;
    }
    setState(() => _loading = true);
    final data = await SearchService.search(q);
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2238),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _c,
            onChanged: _search,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _grid(),
    );
  }

  // ===== GRID мисли Instagram =====
  Widget _grid() {
    if (_items.isEmpty) {
      return const Center(
        child: Text('Nothing found', style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _items.length,
      itemBuilder: (_, i) {
        final it = _items[i];
        final String type = it['type']; // post | user

        return GestureDetector(
          onTap: () {
            if (type == 'user') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProfileScreen(username: it['username']),
                ),
              );
            }
          },
          child: Image.network(
            it['image'],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.black,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}

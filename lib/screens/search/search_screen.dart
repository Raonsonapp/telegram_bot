import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;

  final List<String> _recentSearches = [
    'raonson',
    'flutter',
    'tajik',
    'design',
    'reels',
  ];

  final List<Map<String, dynamic>> _results = List.generate(20, (i) {
    return {
      'username': 'user_$i',
      'verified': i % 4 == 0,
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _searchBar(),
            Expanded(
              child: _isSearching ? _searchResults() : _exploreGrid(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SEARCH BAR =================
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _controller,
        onChanged: (v) {
          setState(() => _isSearching = v.isNotEmpty);
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= SEARCH RESULTS =================
  Widget _searchResults() {
    return ListView(
      children: [
        if (_recentSearches.isNotEmpty) _recentSection(),
        const Divider(color: Colors.grey),
        ..._results.map(_userTile).toList(),
      ],
    );
  }

  Widget _recentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._recentSearches.map((s) {
            return ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(s),
              trailing: const Icon(Icons.close, size: 16),
              onTap: () {
                _controller.text = s;
                setState(() => _isSearching = true);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _userTile(Map<String, dynamic> u) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Row(
        children: [
          Text(u['username']),
          if (u['verified'])
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.verified,
                size: 16,
                color: Colors.green,
              ),
            ),
        ],
      ),
      subtitle: const Text('Raonson user'),
      onTap: () {
        // ҚАДАМИ 32 → Profile by username
      },
    );
  }

  // ================= EXPLORE GRID =================
  Widget _exploreGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 30,
      itemBuilder: (context, i) {
        return Container(
          color: Colors.grey.shade800,
          child: const Center(
            child: Icon(Icons.image, color: Colors.white24),
          ),
        );
      },
    );
  }
}

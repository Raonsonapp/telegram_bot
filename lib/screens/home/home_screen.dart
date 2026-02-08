import 'package:flutter/material.dart';
import '../../core/session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String _me = '';
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _me = await Session.username() ?? '';
    await _loadFeed();
  }

  Future<void> _loadFeed() async {
    // Ҳоло MOCK — сервер баъд
    await Future.delayed(const Duration(milliseconds: 800));

    _posts = List.generate(8, (i) {
      return {
        "id": i,
        "username": "user_$i",
        "caption": "This is post caption #$i",
        "likes": 12 + i,
        "liked": false,
      };
    });

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (_, i) => _postItem(_posts[i]),
              ),
            ),
    );
  }

  // ================= APP BAR =================
  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        "Raonson",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {},
        ),
      ],
    );
  }

  // ================= POST ITEM =================
  Widget _postItem(Map<String, dynamic> post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(
            post['username'],
            style: const TextStyle(color: Colors.white),
          ),
          trailing:
              const Icon(Icons.more_vert, color: Colors.white),
        ),

        // IMAGE (placeholder)
        Container(
          height: 280,
          color: Colors.grey.shade800,
          child: const Center(
            child: Icon(Icons.image, size: 80, color: Colors.white24),
          ),
        ),

        // ACTIONS
        Row(
          children: [
            IconButton(
              icon: Icon(
                post['liked']
                    ? Icons.favorite
                    : Icons.favorite_border,
                color:
                    post['liked'] ? Colors.red : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  post['liked'] = !post['liked'];
                  post['likes'] += post['liked'] ? 1 : -1;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.mode_comment_outlined,
                  color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon:
                  const Icon(Icons.send, color: Colors.white),
              onPressed: () {},
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.bookmark_border,
                  color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),

        // LIKES
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "${post['likes']} likes",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),

        // CAPTION
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${post['username']} ",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                TextSpan(
                  text: post['caption'],
                  style:
                      const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}

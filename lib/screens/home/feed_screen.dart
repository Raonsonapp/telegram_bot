import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<Map<String, dynamic>> _stories = List.generate(10, (i) {
    return {
      'username': 'user_$i',
      'viewed': i % 3 == 0,
    };
  });

  final List<Map<String, dynamic>> _posts = List.generate(5, (i) {
    return {
      'username': 'user_$i',
      'caption': 'Ин як пости намунавии Raonson аст #$i',
      'likes': 12 + i,
      'liked': false,
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(),
      body: ListView(
        children: [
          _storyBar(),
          const Divider(height: 1, color: Colors.grey),
          ..._posts.map(_postCard).toList(),
        ],
      ),
    );
  }

  // ================= APP BAR =================
  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        'Raonson',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.add_box_outlined),
        onPressed: () {
          // ҚАДАМИ 30 → Create Post
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.smart_toy_outlined),
          onPressed: () {
            // AI / Jarvis (баъд)
          },
        ),
      ],
    );
  }

  // ================= STORY BAR =================
  Widget _storyBar() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        itemBuilder: (context, i) {
          final s = _stories[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: s['viewed'] ? Colors.grey : Colors.pink,
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s['username'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= POST CARD =================
  Widget _postCard(Map<String, dynamic> post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            post['username'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.more_vert),
        ),

        // IMAGE PLACEHOLDER
        Container(
          height: 280,
          width: double.infinity,
          color: Colors.grey.shade800,
          child: const Center(
            child: Icon(Icons.image, size: 60, color: Colors.white30),
          ),
        ),

        // ACTIONS
        Row(
          children: [
            IconButton(
              icon: Icon(
                post['liked'] ? Icons.favorite : Icons.favorite_border,
                color: post['liked'] ? Colors.red : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  post['liked'] = !post['liked'];
                  post['likes'] += post['liked'] ? 1 : -1;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.mode_comment_outlined),
              onPressed: () {
                // ҚАДАМИ 31 → Comments
              },
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {},
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {},
            ),
          ],
        ),

        // LIKES
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '${post['likes']} likes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // CAPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white),
              children: [
                TextSpan(
                  text: '${post['username']} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: post['caption']),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}

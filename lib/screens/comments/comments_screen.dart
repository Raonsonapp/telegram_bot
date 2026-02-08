import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  final int postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _comments = [
    {
      'username': 'jarvis',
      'text': '🔥 Very clean UI',
      'time': '1m',
    },
    {
      'username': 'developer',
      'text': 'This looks like Instagram 😎',
      'time': '5m',
    },
  ];

  void _addComment() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _comments.insert(0, {
        'username': 'me',
        'text': _controller.text,
        'time': 'now',
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final c = _comments[index];
                return _commentItem(c);
              },
            ),
          ),

          // INPUT BAR
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade800),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _addComment,
                    child: const Text(
                      'Post',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== COMMENT ITEM =====
  Widget _commentItem(Map<String, dynamic> c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                    text: '${c['username']} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: c['text']),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            c['time'],
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

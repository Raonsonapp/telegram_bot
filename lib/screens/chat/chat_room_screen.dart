import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final String username;
  const ChatRoomScreen({super.key, required this.username});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'me': false, 'text': 'Hello 👋'},
    {'me': true, 'text': 'Hi! Ready to build Raonson 🔥'},
    {'me': false, 'text': 'Yes, let’s go'},
  ];

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'me': true, 'text': _controller.text});
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 8),
            Text(widget.username),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg['me'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color: msg['me']
                          ? Colors.blueAccent
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(msg['text']),
                  ),
                );
              },
            ),
          ),

          // INPUT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

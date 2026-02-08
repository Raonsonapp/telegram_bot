import 'package:flutter/material.dart';
import '../../services/chat_service.dart';

class ChatRoomScreen extends StatefulWidget {
  final int chatId;
  final String username;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.username,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _text = TextEditingController();
  List<dynamic> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ChatService.markAsRead(widget.chatId);
    final data = await ChatService.getMessages(widget.chatId);
    setState(() {
      _messages = data;
      _loading = false;
    });
  }

  Future<void> _send() async {
    if (_text.text.trim().isEmpty) return;
    await ChatService.sendMessage(widget.chatId, _text.text.trim());
    _text.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      final isMe = m['me'] == true;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          padding: const EdgeInsets.all(10),
                          constraints:
                              const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.blue
                                : const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            m['text'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _input(),
        ],
      ),
    );
  }

  Widget _input() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _text,
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}

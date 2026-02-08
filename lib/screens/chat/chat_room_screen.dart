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
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  bool _loading = true;
  List<dynamic> _messages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ChatService.getMessages(widget.chatId);
    await ChatService.markAsRead(widget.chatId);
    setState(() {
      _messages = data;
      _loading = false;
    });
    _scrollDown();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    await ChatService.sendMessage(widget.chatId, text);
    _load();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.username)),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scroll,
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      final me = m['is_me'] == true;
                      return Align(
                        alignment: me
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: me
                                ? Colors.green
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(m['text']),
                        ),
                      );
                    },
                  ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _loading = true;
  List<dynamic> _chats = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ChatService.getChats();
    setState(() {
      _chats = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (_, i) {
                final c = _chats[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(c['username']),
                  subtitle: Text(
                    c['last_message'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: c['unread'] == true
                      ? const CircleAvatar(
                          radius: 6,
                          backgroundColor: Colors.blue,
                        )
                      : null,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          chatId: c['id'],
                          username: c['username'],
                        ),
                      ),
                    );
                    _load();
                  },
                );
              },
            ),
    );
  }
}

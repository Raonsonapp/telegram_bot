import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _mockChats.length,
        itemBuilder: (context, index) {
          final chat = _mockChats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              child: Text(chat['name'][0]),
            ),
            title: Text(chat['name']),
            subtitle: Text(
              chat['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              chat['time'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatRoomScreen(
                    username: chat['name'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ===== MOCK DATA =====
final List<Map<String, dynamic>> _mockChats = [
  {
    'name': 'jarvis',
    'lastMessage': 'Ready for the next build 🚀',
    'time': 'Now',
  },
  {
    'name': 'raonson_team',
    'lastMessage': 'Design approved',
    'time': '12:40',
  },
  {
    'name': 'developer',
    'lastMessage': 'Push the update',
    'time': 'Yesterday',
  },
];

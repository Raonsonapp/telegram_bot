import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/chat_service.dart';
import '../../services/search_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/loading.dart';
import 'chat_room_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = false;
  List<User> _users = [];

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _users = []);
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await SearchService.searchUsers(q);
      setState(() {
        _users = res;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _openChat(User user) async {
    try {
      final chatId = await ChatService.createOrGetChat(user.id);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            chatId: chatId,
            user: user,
          ),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New message'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search users',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Loading()
                : _users.isEmpty
                    ? const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _users.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: Colors.grey.shade300, height: 1),
                        itemBuilder: (context, index) {
                          final u = _users[index];
                          return ListTile(
                            leading: Avatar(imageUrl: u.avatar, size: 44),
                            title: Text(
                              u.username,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: u.bio != null && u.bio!.isNotEmpty
                                ? Text(
                                    u.bio!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            onTap: () => _openChat(u),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

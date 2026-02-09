// lib/screens/chat/chat_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/chat_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import 'chat_room_screen.dart';

/// =====================================================
/// CHAT LIST SCREEN – FINAL v5 (BUILD SAFE)
/// Shows all user chats (Instagram-like)
/// =====================================================
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _loading = true;
  List<ChatItem> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  // ================= LOAD CHATS =================
  Future<void> _loadChats() async {
    try {
      final res = await ChatService.getChats();

      final items = res
          .whereType<Map<String, dynamic>>()
          .map((e) => ChatItem.fromJson(e))
          .toList();

      if (!mounted) return;
      setState(() {
        _chats = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _openChat(ChatItem chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          chatId: chat.chatId,
          user: chat.user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: Loading())
          : _chats.isEmpty
              ? const EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'No messages',
                  subtitle: 'Start a conversation to see it here',
                )
              : ListView.separated(
                  itemCount: _chats.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final chat = _chats[index];
                    return _ChatTile(
                      chat: chat,
                      onTap: () => _openChat(chat),
                    );
                  },
                ),
    );
  }
}

/// =====================================================
/// CHAT TILE
class _ChatTile extends StatelessWidget {
  final ChatItem chat;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Avatar(
        imageUrl: chat.user.avatarUrl,
        size: 44,
      ),
      title: Text(
        chat.user.username,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        chat.lastMessage?.text ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: chat.unreadCount > 0
          ? CircleAvatar(
              radius: 10,
              backgroundColor:
                  Theme.of(context).colorScheme.primary,
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}

/// =====================================================
/// CHAT ITEM (UI MODEL)
class ChatItem {
  final String chatId;
  final User user;
  final Message? lastMessage;
  final int unreadCount;

  ChatItem({
    required this.chatId,
    required this.user,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      chatId: json['chat_id']?.toString() ?? '',
      user: User.fromJson(json['user']),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

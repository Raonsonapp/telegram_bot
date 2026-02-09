import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/avatar_widget.dart';
import '../../widgets/loading_widget.dart';
import '../chat_repository.dart';
import 'chat_list_controller.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatListController(ChatRepository()),
      child: Consumer<ChatListController>(
        builder: (context, controller, _) {
          if (controller.state.loading) {
            return const Center(child: LoadingWidget());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...controller.state.items.map(
                (message) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: AvatarWidget(imageUrl: message.avatarUrl, size: 48),
                  title: Text(
                    message.username,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(message.lastMessage),
                  trailing: Text(message.timeAgo),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

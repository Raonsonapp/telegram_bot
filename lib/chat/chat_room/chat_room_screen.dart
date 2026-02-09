import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_room_controller.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatRoomController(),
      child: Consumer<ChatRoomController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: controller.state.messages
                  .map(
                    (message) => Align(
                      alignment: message.username == 'me'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: message.username == 'me'
                              ? Colors.blueAccent
                              : Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(message.lastMessage),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

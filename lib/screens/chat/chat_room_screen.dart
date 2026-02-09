// lib/screens/chat/chat_room_screen.dart

import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/chat_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/loading.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final User user;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.user,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool _loading = true;
  bool _sending = false;
  List<Message> _messages = [];

  int? _myUserId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _myUserId = await Session.getUserId();
    await _loadMessages();
  }

  // ================= LOAD MESSAGES =================
  Future<void> _loadMessages() async {
    try {
      final data = await ChatService.getMessages(widget.chatId);
      if (!mounted) return;
      setState(() {
        _messages = data;
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ================= SEND MESSAGE =================
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      final message = await ChatService.sendMessage(
        chatId: widget.chatId,
        text: text,
      );

      if (message != null && mounted) {
        setState(() {
          _messages.add(message);
          _controller.clear();
        });
        _scrollToBottom();
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  // ================= SCROLL =================
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Avatar(
              imageUrl: widget.user.avatarUrl,
              size: 36,
            ),
            const SizedBox(width: 10),
            Text(
              widget.user.username,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ===== MESSAGES =====
          Expanded(
            child: _loading
                ? const Loading()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = _myUserId != null &&
                          msg.sender.id == _myUserId;

                      return ChatBubble(
                        message: msg.text,
                        isMe: isMe,
                        createdAt: msg.createdAt,
                        isRead: msg.isRead,
                      );
                    },
                  ),
          ),

          // ===== INPUT =====
          _InputBar(
            controller: _controller,
            sending: _sending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------
/// MESSAGE INPUT BAR
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.sending,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Message…',
                  border: InputBorder.none,
                ),
              ),
            ),
            sending
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: onSend,
                  ),
          ],
        ),
      ),
    );
  }
}

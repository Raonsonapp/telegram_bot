import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/chat_service.dart';
import '../../services/report_service.dart';
import '../../widgets/avatar.dart';

class MessageInfoScreen extends StatelessWidget {
  final Message message;
  final User otherUser;

  const MessageInfoScreen({
    super.key,
    required this.message,
    required this.otherUser,
  });

  String _format(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd MMM yyyy • HH:mm').format(dt);
  }

  Future<void> _deleteMessage(BuildContext context) async {
    try {
      await ChatService.deleteMessage(message.id);
      if (context.mounted) Navigator.pop(context, true);
    } catch (_) {}
  }

  Future<void> _reportMessage(BuildContext context) async {
    try {
      await ReportService.reportMessage(
        messageId: message.id,
        reason: 'Inappropriate message',
      );
      if (context.mounted) Navigator.pop(context);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message info'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // USER
          Row(
            children: [
              Avatar(imageUrl: otherUser.avatar, size: 48),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUser.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isMine ? 'Sent to user' : 'Received from user',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 24),

          // MESSAGE
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              style: const TextStyle(fontSize: 15),
            ),
          ),

          const SizedBox(height: 24),

          // INFO
          _infoRow('Sent', _format(message.createdAt)),
          _infoRow('Delivered', _format(message.deliveredAt)),
          _infoRow('Read', _format(message.readAt)),

          const SizedBox(height: 32),

          // ACTIONS
          if (isMine)
            _actionButton(
              context,
              icon: Icons.delete_outline,
              title: 'Delete message',
              color: Colors.red,
              onTap: () => _deleteMessage(context),
            ),

          _actionButton(
            context,
            icon: Icons.report_outlined,
            title: 'Report message',
            color: Colors.orange,
            onTap: () => _reportMessage(context),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}

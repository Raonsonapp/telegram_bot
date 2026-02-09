// lib/screens/notifications/notifications_screen.dart

import 'package:flutter/material.dart';

import '../../services/notification_service.dart';
import '../profile/profile_screen.dart';
import '../comments/comments_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ================= LOAD =================
  Future<void> _load() async {
    try {
      final data =
          await NotificationService.getNotifications();

      if (!mounted) return;
      setState(() {
        _items = data
            .whereType<Map<String, dynamic>>()
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ================= OPEN =================
  Future<void> _open(Map<String, dynamic> n) async {
    final String id = n['id'].toString();
    final String type = n['type'] ?? '';
    final String username =
        n['from_user']?['username'] ?? '';
    final int? targetId = n['target_id'];

    await NotificationService.markAsRead(id);

    if (!mounted) return;

    if (type == 'follow') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProfileScreen(username: username),
        ),
      );
    } else if (targetId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CommentsScreen(postId: targetId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await NotificationService.markAllAsRead();
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _items.isEmpty
              ? const Center(
                  child: Text('No notifications'),
                )
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 0),
                  itemBuilder: (_, i) {
                    final n = _items[i];
                    final bool read =
                        n['is_read'] == true;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          _iconByType(n['type']),
                        ),
                      ),
                      title: Text(
                        _titleByType(n),
                        style: TextStyle(
                          fontWeight: read
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      trailing: read
                          ? null
                          : const Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.green,
                            ),
                      onTap: () => _open(n),
                    );
                  },
                ),
    );
  }

  // ================= HELPERS =================
  IconData _iconByType(String? t) {
    switch (t) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.mode_comment;
      case 'follow':
        return Icons.person_add;
      case 'message':
        return Icons.chat;
      default:
        return Icons.notifications;
    }
  }

  String _titleByType(Map<String, dynamic> n) {
    final u = n['from_user']?['username'] ?? '';
    switch (n['type']) {
      case 'like':
        return '$u liked your post';
      case 'comment':
        return '$u commented on your post';
      case 'follow':
        return '$u started following you';
      case 'message':
        return 'New message from $u';
      default:
        return 'Notification';
    }
  }
}

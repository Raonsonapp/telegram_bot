import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../profile/profile_screen.dart';
import '../comments/comments_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await NotificationService.getAll();
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _open(dynamic n) async {
    final int id = n['id'];
    final String type = n['type']; // like, comment, follow
    final String username = n['from_username'] ?? '';
    final int? postId = n['post_id'];

    await NotificationService.markRead(id);

    if (type == 'follow') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(username: username),
        ),
      );
    } else if (postId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommentsScreen(postId: postId),
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
              await NotificationService.markAllRead();
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
                    final bool read = n['read'] == true;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          _iconByType(n['type']),
                        ),
                      ),
                      title: Text(
                        _titleByType(n),
                        style: TextStyle(
                          fontWeight:
                              read ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      trailing: read
                          ? null
                          : const Icon(Icons.circle,
                              size: 8, color: Colors.green),
                      onTap: () => _open(n),
                    );
                  },
                ),
    );
  }

  IconData _iconByType(String t) {
    switch (t) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.mode_comment;
      case 'follow':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  String _titleByType(dynamic n) {
    final u = n['from_username'] ?? '';
    switch (n['type']) {
      case 'like':
        return '$u liked your post';
      case 'comment':
        return '$u commented on your post';
      case 'follow':
        return '$u started following you';
      default:
        return 'Notification';
    }
  }
}

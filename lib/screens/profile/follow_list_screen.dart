import 'package:flutter/material.dart';
import '../../services/follow_service.dart';
import 'profile_screen.dart';

class FollowListScreen extends StatefulWidget {
  final String username;
  final bool isFollowers;

  const FollowListScreen({
    super.key,
    required this.username,
    required this.isFollowers,
  });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  bool _loading = true;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = widget.isFollowers
        ? await FollowService.getFollowers(widget.username)
        : await FollowService.getFollowing(widget.username);

    setState(() {
      _users = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFollowers ? 'Followers' : 'Following'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (_, i) {
                final u = _users[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Row(
                    children: [
                      Text(u['username']),
                      if (u['verified'] == true)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.verified,
                            size: 16,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(u['bio'] ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfileScreen(username: u['username']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

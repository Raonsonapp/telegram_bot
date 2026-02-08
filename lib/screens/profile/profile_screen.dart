import 'package:flutter/material.dart';
import '../../services/follow_service.dart';
import '../../services/post_service.dart';
import 'follow_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  Map<String, dynamic>? _user;
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await PostService.getUser(widget.username);
    final posts = await PostService.getByUser(widget.username);

    setState(() {
      _user = user;
      _posts = posts;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(_user!['username']),
            if (_user!['verified'] == true)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.verified, color: Colors.green, size: 18),
              ),
          ],
        ),
      ),
      body: ListView(
        children: [
          _header(),
          const Divider(),
          _grid(),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 8),
          Text(_user!['bio'] ?? ''),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _count('Posts', _posts.length),
              _count(
                'Followers',
                _user!['followers'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FollowListScreen(
                        username: widget.username,
                        isFollowers: true,
                      ),
                    ),
                  );
                },
              ),
              _count(
                'Following',
                _user!['following'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FollowListScreen(
                        username: widget.username,
                        isFollowers: false,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _followButton(),
        ],
      ),
    );
  }

  Widget _followButton() {
    final bool isFollowing = _user!['is_following'] == true;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (isFollowing) {
            await FollowService.unfollowUser(_user!['id']);
          } else {
            await FollowService.followUser(_user!['id']);
          }
          _load();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.grey[800] : Colors.blue,
        ),
        child: Text(isFollowing ? 'Unfollow' : 'Follow'),
      ),
    );
  }

  Widget _count(String label, int value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      ),
    );
  }

  Widget _grid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (_, i) {
        return Image.network(
          _posts[i]['image_url'],
          fit: BoxFit.cover,
        );
      },
    );
  }
}

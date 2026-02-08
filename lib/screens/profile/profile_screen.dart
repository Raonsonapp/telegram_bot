import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/follow_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = UserModel(
      id: 1,
      username: 'raonson',
      avatar: '',
      bio: 'Raonson official 🚀',
      followers: 1240,
      following: 120,
      isVerified: true,
      isFollowing: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Text(user.username),
            if (user.isVerified)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.verified, color: Colors.green, size: 18),
              )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        children: [
          _header(),
          _bio(),
          _buttons(),
          _stats(),
          _grid(),
        ],
      ),
    );
  }

  // HEADER
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 40),
          ),
          const SizedBox(width: 20),
          _statItem('Posts', '24'),
          _statItem('Followers', user.followers.toString()),
          _statItem('Following', user.following.toString()),
        ],
      ),
    );
  }

  Widget _statItem(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // BIO
  Widget _bio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        user.bio,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // BUTTONS
  Widget _buttons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    user.isFollowing ? Colors.grey[800] : Colors.blue,
              ),
              onPressed: () {
                setState(() {
                  FollowService.toggleFollow(user);
                });
              },
              child: Text(user.isFollowing ? 'Following' : 'Follow'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Message'),
            ),
          ),
        ],
      ),
    );
  }

  // STATS BAR
  Widget _stats() {
    return const Divider(color: Colors.grey);
  }

  // GRID POSTS
  Widget _grid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemBuilder: (_, i) {
        return Container(
          color: Colors.grey[900],
          child: const Icon(Icons.image, color: Colors.grey),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/avatar_widget.dart';
import '../../widgets/verified_badge.dart';
import '../profile_repository.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(ProfileRepository()),
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          final user = controller.state.user;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  AvatarWidget(imageUrl: user.avatarUrl, size: 90),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const VerifiedBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('@${user.username}'),
                        const SizedBox(height: 6),
                        Text(user.bio),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatTile(value: user.posts, label: 'Posts'),
                  _StatTile(value: user.followers, label: 'Followers'),
                  _StatTile(value: user.following, label: 'Following'),
                ],
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
                    fit: BoxFit.cover,
                  ),
                ),
                itemCount: 6,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

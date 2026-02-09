import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../chat/chat_list/chat_list_screen.dart';
import '../home/feed/feed_screen.dart';
import '../profile/profile_main/profile_screen.dart';
import '../reels/reels_feed/reels_screen.dart';
import '../search/search_main/search_screen.dart';
import 'nav_controller.dart';

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavController(),
      child: Consumer<NavController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Raonson'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            body: IndexedStack(
              index: controller.index,
              children: const [
                FeedScreen(),
                ReelsScreen(),
                SearchScreen(),
                ChatListScreen(),
                ProfileScreen(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: controller.index,
              onDestinationSelected: controller.updateIndex,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(
                  icon: Icon(Icons.video_library_outlined),
                  label: 'Reels',
                ),
                NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  label: 'Chat',
                ),
                NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          );
        },
      ),
    );
  }
}

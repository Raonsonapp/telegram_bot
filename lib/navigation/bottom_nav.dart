import 'package:flutter/material.dart';

// Screens
import '../screens/home/home_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _index = 0;

  final List<Widget> _screens = const [
    HomeScreen(),        // Home
    _SearchStub(),       // Search
    _ReelsStub(),        // Reels
    _ChatStub(),         // Chat
    _ProfileStub(),     // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle_fill),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/* ================= PLACEHOLDER SCREENS ================= */

class _SearchStub extends StatelessWidget {
  const _SearchStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Search',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}

class _ReelsStub extends StatelessWidget {
  const _ReelsStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Reels',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}

class _ChatStub extends StatelessWidget {
  const _ChatStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Chat',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}

class _ProfileStub extends StatelessWidget {
  const _ProfileStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}

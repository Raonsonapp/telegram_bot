import 'package:flutter/material.dart';

void main() {
  runApp(const RaonsonApp());
}

class RaonsonApp extends StatelessWidget {
  const RaonsonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raonson',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B3EFF),
          primary: const Color(0xFF5B3EFF),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
        ),
        useMaterial3: true,
      ),
      home: const RaonsonHomePage(),
    );
  }
}

class RaonsonHomePage extends StatelessWidget {
  const RaonsonHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Raonson',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Color(0xFF1F1F23),
            letterSpacing: 0.2,
          ),
        ),
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: const [
          StoriesStrip(),
          SizedBox(height: 12),
          FeedCard(
            username: 'raonson.travel',
            location: 'Dushanbe, TJ',
            imageLabel: 'Mountain escape',
            likes: '14,829',
            caption:
                'Шоми ором дар кӯҳҳо. Ҳар рӯзро бо илҳом оғоз мекунем ✨',
            timeAgo: '2 hours ago',
          ),
          FeedCard(
            username: 'raonson.studio',
            location: 'Creative Lab',
            imageLabel: 'Studio vibes',
            likes: '9,203',
            caption:
                'Эҷодиёти дастаи Raonson — ранги нав барои ҳар лоиҳа.',
            timeAgo: '5 hours ago',
          ),
          FeedCard(
            username: 'raonson.food',
            location: 'City Market',
            imageLabel: 'Fresh bites',
            likes: '6,451',
            caption: 'Таомҳои нав барои дӯстдорони маззаҳои махсус.',
            timeAgo: '1 day ago',
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_filled), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.add_box_outlined), label: 'Post'),
          NavigationDestination(icon: Icon(Icons.video_library_outlined), label: 'Reels'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class StoriesStrip extends StatelessWidget {
  const StoriesStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = [
      _StoryData(name: 'You', isLive: true),
      _StoryData(name: 'Alina'),
      _StoryData(name: 'Said'),
      _StoryData(name: 'Nastya'),
      _StoryData(name: 'Dilshod'),
      _StoryData(name: 'Mariam'),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) => StoryBubble(data: stories[index]),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: stories.length,
      ),
    );
  }
}

class StoryBubble extends StatelessWidget {
  const StoryBubble({super.key, required this.data});

  final _StoryData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFD7A5C), Color(0xFF5B3EFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    data.name.substring(0, 1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F23),
                    ),
                  ),
                ),
              ),
            ),
            if (data.isLive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA4C89),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          data.name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.username,
    required this.location,
    required this.imageLabel,
    required this.likes,
    required this.caption,
    required this.timeAgo,
  });

  final String username;
  final String location;
  final String imageLabel;
  final String likes;
  final String caption;
  final String timeAgo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF5B3EFF),
              child: Text(
                username.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(location),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ),
          Container(
            height: 240,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFB8C6FF), Color(0xFFFFD8D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                imageLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F23),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.mode_comment_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined),
                  onPressed: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '$likes likes',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF1F1F23)),
                children: [
                  TextSpan(
                    text: username,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: '  '),
                  TextSpan(text: caption),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              timeAgo,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryData {
  _StoryData({required this.name, this.isLive = false});

  final String name;
  final bool isLive;
}

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ===== MOCK DATA (UI ONLY — server later) =====
  final List<Map<String, dynamic>> stories = [
    {"name": "Your story", "img": "https://picsum.photos/200?1", "me": true},
    {"name": "ardamehr", "img": "https://picsum.photos/200?2"},
    {"name": "mehrat", "img": "https://picsum.photos/200?3"},
    {"name": "qurbiddin", "img": "https://picsum.photos/200?4"},
    {"name": "shohrukh", "img": "https://picsum.photos/200?5"},
  ];

  final List<Map<String, dynamic>> posts = [
    {
      "user": "ardamehr",
      "avatar": "https://picsum.photos/200?11",
      "image": "https://picsum.photos/800/900?21",
      "caption": "Good day ✨",
      "likes": 128,
      "comments": 14,
      "liked": false,
    },
    {
      "user": "mehrat",
      "avatar": "https://picsum.photos/200?12",
      "image": "https://picsum.photos/800/900?22",
      "caption": "Chillin 😎",
      "likes": 342,
      "comments": 33,
      "liked": true,
    },
  ];

  int _navIndex = 0;

  // ===== THEME =====
  static const bg = Color(0xFF070B16);
  static const card = Color(0xFF0F1424);
  static const glow = Color(0xFF4DA3FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: _appBar(),
      body: Column(
        children: [
          _storiesBar(),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: posts.length,
              itemBuilder: (_, i) => _postCard(i),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ================= APP BAR =================
  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      title: const Text(
        "Raonson",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.camera_alt_outlined),
        ),
      ],
    );
  }

  // ================= STORIES =================
  Widget _storiesBar() {
    return SizedBox(
      height: 98,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final s = stories[i];
          return Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5AB0FF), Color(0xFF7C5CFF)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: glow,
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(s["img"]),
                  child: s["me"] == true
                      ? const Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: glow,
                            child: Icon(Icons.add, size: 14, color: Colors.black),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 72,
                child: Text(
                  s["name"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: stories.length,
      ),
    );
  }

  // ================= POST CARD =================
  Widget _postCard(int index) {
    final p = posts[index];
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(p["avatar"])),
            title: Text(p["user"], style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.more_vert),
          ),

          // IMAGE
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Image.network(
              p["image"],
              fit: BoxFit.cover,
            ),
          ),

          // ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    p["liked"] ? Icons.favorite : Icons.favorite_border,
                    color: p["liked"] ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      p["liked"] = !p["liked"];
                      p["likes"] += p["liked"] ? 1 : -1;
                    });
                  },
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

          // COUNTS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "${p["likes"]} likes",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // CAPTION
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                    text: "${p["user"]} ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: p["caption"]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM NAV =================
  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(color: glow, blurRadius: 20, spreadRadius: -10),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: bg,
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: "Reels"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

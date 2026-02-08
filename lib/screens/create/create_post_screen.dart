import 'package:flutter/material.dart';
import '../../services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _caption = TextEditingController();
  bool _loading = false;

  // Ҳоло mock media (қадамҳои баъдӣ: image_picker)
  final String _mediaUrl =
      'https://placehold.co/600x600/png'; // placeholder

  Future<void> _submit() async {
    if (_loading) return;

    setState(() => _loading = true);
    try {
      await PostService.createPost(
        caption: _caption.text,
        mediaUrl: _mediaUrl,
      );
      Navigator.pop(context, true);
    } catch (_) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New post'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Share',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // MEDIA PREVIEW
          Container(
            height: 300,
            width: double.infinity,
            color: const Color(0xFF111111),
            child: Image.network(
              _mediaUrl,
              fit: BoxFit.cover,
            ),
          ),

          // CAPTION
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _caption,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

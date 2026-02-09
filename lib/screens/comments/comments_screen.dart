import 'package:flutter/material.dart';

import '../../services/comment_service.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';

class CommentsScreen extends StatefulWidget {
  final int postId;

  const CommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _loading = true;
  bool _sending = false;
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  // ================= LOAD COMMENTS =================
  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      final data = await CommentService.getComments(widget.postId);
      setState(() => _comments = data);
    } catch (_) {
      setState(() => _comments = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= ADD COMMENT =================
  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      final comment = await CommentService.addComment(
        postId: widget.postId,
        text: text,
      );

      setState(() {
        _comments.insert(0, comment);
        _controller.clear();
      });
    } catch (_) {
      // silent fail
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // ===== COMMENTS LIST =====
          Expanded(
            child: _loading
                ? const Center(child: Loading())
                : _comments.isEmpty
                    ? const EmptyState(
                        icon: Icons.mode_comment_outlined,
                        title: 'No comments',
                        subtitle: 'Be the first to comment',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadComments,
                        child: ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(12),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final c = _comments[index];
                            return _commentItem(c);
                          },
                        ),
                      ),
          ),

          // ===== INPUT BAR =====
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade800),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _addComment(),
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton(
                          onPressed: _addComment,
                          child: const Text(
                            'Post',
                            style:
                                TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMMENT ITEM =================
  Widget _commentItem(Map<String, dynamic> c) {
    final username = c['username'] ?? '';
    final text = c['text'] ?? '';
    final createdAt = c['created_at'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                    text: '$username ',
                    style:
                        const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(createdAt),
            style:
                const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    return raw; // backend can return formatted or ISO
  }
}

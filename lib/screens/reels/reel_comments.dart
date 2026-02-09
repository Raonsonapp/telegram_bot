import 'package:flutter/material.dart';

import '../../models/comment.dart';
import '../../services/comment_service.dart';
import '../../core/session.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';

/// Reels Comments Screen
/// Version: v5 FULL
class ReelCommentsScreen extends StatefulWidget {
  final int reelId;

  const ReelCommentsScreen({
    super.key,
    required this.reelId,
  });

  @override
  State<ReelCommentsScreen> createState() => _ReelCommentsScreenState();
}

class _ReelCommentsScreenState extends State<ReelCommentsScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Comment> _comments = [];

  bool _loading = true;
  bool _sending = false;
  String _me = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _me = await Session.getUsername() ?? '';
    await _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      final data = await CommentService.getReelComments(widget.reelId);
      setState(() {
        _comments
          ..clear()
          ..addAll(data);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendComment() async {
    if (_controller.text.trim().isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      final comment = await CommentService.addReelComment(
        reelId: widget.reelId,
        text: _controller.text.trim(),
      );

      setState(() {
        _comments.insert(0, comment);
        _controller.clear();
      });
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(),
      body: Column(
        children: [
          Expanded(child: _body()),
          _inputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: const Text(
        'Comments',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Widget _body() {
    if (_loading) return const Loading();

    if (_comments.isEmpty) {
      return const EmptyState(
        icon: Icons.chat_bubble_outline,
        text: 'No comments yet',
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: _comments.length,
      itemBuilder: (_, i) => _commentItem(_comments[i]),
    );
  }

  // =====================================================
  // COMMENT ITEM
  // =====================================================
  Widget _commentItem(Comment c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage:
                c.userAvatar.isNotEmpty ? NetworkImage(c.userAvatar) : null,
            child: c.userAvatar.isEmpty
                ? const Icon(Icons.person, size: 18)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                    text: c.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (c.isVerified) const WidgetSpan(child: SizedBox(width: 4)),
                  if (c.isVerified)
                    const WidgetSpan(child: VerifiedBadge()),
                  const TextSpan(text: '  '),
                  TextSpan(text: c.text),
                ],
              ),
            ),
          ),
          if (c.username == _me)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.grey),
              onPressed: () async {
                await CommentService.deleteComment(c.id);
                setState(() => _comments.remove(c));
              },
            ),
        ],
      ),
    );
  }

  // =====================================================
  // INPUT BAR
  // =====================================================
  Widget _inputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.white12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ),
            _sending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendComment,
                  ),
          ],
        ),
      ),
    );
  }
}

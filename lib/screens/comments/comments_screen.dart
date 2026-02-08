import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../services/post_service.dart';
import 'comment_item.dart';

class CommentsScreen extends StatefulWidget {
  final int postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  bool _loading = true;
  List<dynamic> _comments = [];
  final TextEditingController _controller = TextEditingController();
  String _me = '';
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _me = await Session.getToken() ?? '';
    await _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final data = await PostService.getComments(widget.postId);
      setState(() {
        _comments = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      await PostService.addComment(
        postId: widget.postId,
        text: text,
      );
      _controller.clear();
      await _loadComments();
    } catch (_) {}

    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      return CommentItem(
                        comment: _comments[index],
                        me: _me,
                      );
                    },
                  ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Add a comment…',
                  border: InputBorder.none,
                ),
              ),
            ),
            TextButton(
              onPressed: _sending ? null : _sendComment,
              child: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}

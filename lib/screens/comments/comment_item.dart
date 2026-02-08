import 'package:flutter/material.dart';

class CommentItem extends StatelessWidget {
  final dynamic comment;
  final String me;

  const CommentItem({
    super.key,
    required this.comment,
    required this.me,
  });

  @override
  Widget build(BuildContext context) {
    final String username = comment['username'] ?? '';
    final String text = comment['text'] ?? '';
    final bool isMe = username == me;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                    text: '$username ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.blueAccent : Colors.white,
                    ),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

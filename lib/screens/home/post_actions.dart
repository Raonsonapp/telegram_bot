import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../services/follow_service.dart';
import '../../core/session.dart';
import '../comments/comments_screen.dart';

class PostActions {
  /// ================= LIKE / UNLIKE =================
  static Future<void> toggleLike({
    required BuildContext context,
    required Post post,
    required VoidCallback onUpdated,
  }) async {
    try {
      final me = await Session.getToken();
      if (me == null) return;

      if (post.isLiked) {
        await PostService.unlikePost(post.id);
      } else {
        await PostService.likePost(post.id);
      }

      onUpdated();
    } catch (e) {
      _showError(context, 'Failed to like post');
    }
  }

  /// ================= SAVE / UNSAVE =================
  static Future<void> toggleSave({
    required BuildContext context,
    required Post post,
    required VoidCallback onUpdated,
  }) async {
    try {
      if (post.isSaved) {
        await PostService.unsavePost(post.id);
      } else {
        await PostService.savePost(post.id);
      }

      onUpdated();
    } catch (e) {
      _showError(context, 'Failed to save post');
    }
  }

  /// ================= OPEN COMMENTS =================
  static void openComments({
    required BuildContext context,
    required int postId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentsScreen(postId: postId),
      ),
    );
  }

  /// ================= SHARE =================
  static Future<void> sharePost({
    required BuildContext context,
    required Post post,
  }) async {
    try {
      // Placeholder for real share (deep link / dynamic link)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post shared'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      _showError(context, 'Failed to share post');
    }
  }

  /// ================= FOLLOW USER =================
  static Future<void> followUser({
    required BuildContext context,
    required String userId,
    required VoidCallback onUpdated,
  }) async {
    try {
      await FollowService.followUser(userId);
      onUpdated();
    } catch (e) {
      _showError(context, 'Failed to follow user');
    }
  }

  /// ================= UNFOLLOW USER =================
  static Future<void> unfollowUser({
    required BuildContext context,
    required String userId,
    required VoidCallback onUpdated,
  }) async {
    try {
      await FollowService.unfollowUser(userId);
      onUpdated();
    } catch (e) {
      _showError(context, 'Failed to unfollow user');
    }
  }

  /// ================= ERROR =================
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

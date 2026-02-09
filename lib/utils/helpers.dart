/// lib/utils/helpers.dart
/// General helpers for Raonson App
/// Version: v5 (Full Social Network)

import 'dart:math';
import 'package:flutter/material.dart';

class Helpers {
  Helpers._();

  // ================= CONTEXT =================
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double statusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  // ================= SNACKBAR =================
  static void showSnack(
    BuildContext context,
    String message, {
    bool error = false,
  }) {
    final snack = SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red : Colors.black,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snack);
  }

  // ================= DIALOG =================
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String okText = 'OK',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(okText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // ================= SAFE CALL =================
  static Future<void> safeAsync(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      showSnack(context, e.toString(), error: true);
    }
  }

  // ================= STRING =================
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // ================= RANDOM =================
  static String randomId({int length = 12}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();

    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  // ================= SCROLL =================
  static void scrollToTop(ScrollController controller) {
    if (!controller.hasClients) return;

    controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ================= DELAY =================
  static Future<void> wait(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  // ================= FILE SIZE =================
  /// bytes -> KB / MB
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';

    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

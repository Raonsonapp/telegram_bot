/// lib/utils/formatters.dart
/// Central formatters for Raonson App
/// Version: v5 (Full Social Network)

class Formatters {
  Formatters._();

  // ================= TIME AGO =================
  /// Example:
  /// 5s, 3m, 2h, 1d, 2w
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays}d';
    }

    final weeks = (diff.inDays / 7).floor();
    return '${weeks}w';
  }

  // ================= FULL DATE =================
  /// Example: 12 Aug 2026
  static String fullDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ================= NUMBER =================
  /// Example:
  /// 1200 -> 1.2K
  /// 3400000 -> 3.4M
  static String compactNumber(int value) {
    if (value < 1000) return value.toString();

    if (value < 1000000) {
      final n = value / 1000;
      return '${n.toStringAsFixed(n < 10 ? 1 : 0)}K';
    }

    final n = value / 1000000;
    return '${n.toStringAsFixed(n < 10 ? 1 : 0)}M';
  }

  // ================= PHONE =================
  /// +992xxxxxxxxx -> +992 xx xxx xx xx
  static String phone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 9) return raw;

    if (digits.startsWith('992')) {
      return '+992 ${digits.substring(3, 5)} '
          '${digits.substring(5, 8)} '
          '${digits.substring(8, 10)} '
          '${digits.substring(10)}';
    }

    return raw;
  }

  // ================= USERNAME =================
  static String username(String username) {
    return '@$username';
  }

  // ================= CAPTION =================
  /// Limit caption preview (feed)
  static String captionPreview(String text, {int max = 120}) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}…';
  }

  // ================= CHAT TIME =================
  /// Example: 14:32
  static String chatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ================= MESSAGE STATUS =================
  static String messageStatus(bool read) {
    return read ? 'Seen' : 'Sent';
  }
}

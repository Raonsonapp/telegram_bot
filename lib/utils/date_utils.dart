class DateUtilsRaonson {
  DateUtilsRaonson._();

  /// Қабул мекунад:
  /// - DateTime
  /// - String (ISO: 2025-02-06T12:30:00Z)
  ///
  /// Бармегардонад:
  /// just now, 5m, 2h, yesterday, 3d, 12 Jan
  static String format(dynamic date) {
    if (date == null) return '';

    DateTime time;
    if (date is DateTime) {
      time = date;
    } else if (date is String) {
      time = DateTime.tryParse(date) ?? DateTime.now();
    } else {
      return '';
    }

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 30) {
      return 'just now';
    }

    if (diff.inMinutes < 1) {
      return '${diff.inSeconds}s';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }

    if (diff.inDays == 1) {
      return 'yesterday';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays}d';
    }

    return _formatDate(time);
  }

  // ====== DATE FORMAT: 12 Jan ======
  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final day = date.day;
    final month = months[date.month - 1];

    return '$day $month';
  }
}

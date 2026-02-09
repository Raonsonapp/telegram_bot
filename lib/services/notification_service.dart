/// lib/services/notification_service.dart
/// =====================================================
/// NOTIFICATION SERVICE – FINAL v5.1 (BUILD SAFE)
/// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/notification.dart';

class NotificationService {
  // =====================================================
  // GET ALL NOTIFICATIONS
  // =====================================================
  static Future<List<AppNotification>> getAll() async {
    final res = await HttpService.get(
      Api.notifications,
      auth: true,
    );

    if (res is List) {
      return res
          .map<AppNotification>(
              (e) => AppNotification.fromJson(e))
          .toList();
    }

    return [];
  }

  // =====================================================
  // GET UNREAD COUNT
  // =====================================================
  static Future<int> getUnreadCount() async {
    final res = await HttpService.get(
      Api.notificationsUnreadCount,
      auth: true,
    );

    if (res is Map && res['count'] is int) {
      return res['count'];
    }

    return 0;
  }

  // =====================================================
  // MARK ONE AS READ
  // =====================================================
  static Future<void> markRead(int notificationId) async {
    await HttpService.post(
      Api.markNotificationRead(notificationId),
      {},
      auth: true,
    );
  }

  // =====================================================
  // MARK ALL AS READ
  // =====================================================
  static Future<void> markAllRead() async {
    await HttpService.post(
      Api.markAllNotificationsRead,
      {},
      auth: true,
    );
  }

  // =====================================================
  // DELETE ONE
  // =====================================================
  static Future<void> delete(int notificationId) async {
    await HttpService.delete(
      Api.deleteNotification(notificationId),
      auth: true,
    );
  }

  // =====================================================
  // CLEAR ALL
  // =====================================================
  static Future<void> clear() async {
    await HttpService.delete(
      Api.clearNotifications,
      auth: true,
    );
  }
}

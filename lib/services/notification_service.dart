/// lib/services/notification_service.dart
/// =====================================================
/// NOTIFICATION SERVICE – FINAL v5 (FIXED)
/// Handles:
/// - Notifications list
/// - Unread count
/// - Mark read
/// - Delete / Clear
/// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/notification.dart';

class NotificationService {
  // =====================================================
  // GET ALL NOTIFICATIONS
  // =====================================================
  /// GET /notifications
  static Future<List<AppNotification>> getNotifications() async {
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
  /// GET /notifications/unread-count
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
  // MARK ONE NOTIFICATION AS READ
  // =====================================================
  /// POST /notifications/{id}/read
  static Future<void> markAsRead(int notificationId) async {
    await HttpService.post(
      Api.markNotificationRead(notificationId),
      body: {},
      auth: true,
    );
  }

  // =====================================================
  // MARK ALL AS READ
  // =====================================================
  /// POST /notifications/read-all
  static Future<void> markAllAsRead() async {
    await HttpService.post(
      Api.markAllNotificationsRead,
      body: {},
      auth: true,
    );
  }

  // =====================================================
  // DELETE ONE NOTIFICATION
  // =====================================================
  /// DELETE /notifications/{id}
  static Future<void> deleteNotification(int notificationId) async {
    await HttpService.delete(
      Api.deleteNotification(notificationId),
      auth: true,
    );
  }

  // =====================================================
  // CLEAR ALL NOTIFICATIONS
  // =====================================================
  /// DELETE /notifications/clear
  static Future<void> clearAll() async {
    await HttpService.delete(
      Api.clearNotifications,
      auth: true,
    );
  }
}

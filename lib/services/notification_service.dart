// lib/services/notification_service.dart

import '../core/api.dart';
import '../core/http_service.dart';
import '../core/session.dart';

class NotificationService {
  // =========================
  // GET ALL NOTIFICATIONS
  // =========================
  static Future<List<dynamic>> getNotifications() async {
    final res = await HttpService.get(
      '${Api.baseUrl}/notifications',
      auth: true,
    );

    if (res is List) {
      return res;
    }

    return [];
  }

  // =========================
  // GET UNREAD COUNT
  // =========================
  static Future<int> getUnreadCount() async {
    final res = await HttpService.get(
      '${Api.baseUrl}/notifications/unread-count',
      auth: true,
    );

    if (res is Map && res['count'] != null) {
      return res['count'] as int;
    }

    return 0;
  }

  // =========================
  // MARK ONE NOTIFICATION AS READ
  // =========================
  static Future<bool> markAsRead(String notificationId) async {
    final res = await HttpService.post(
      '${Api.baseUrl}/notifications/$notificationId/read',
      {},
      auth: true,
    );

    return res != null;
  }

  // =========================
  // MARK ALL AS READ
  // =========================
  static Future<bool> markAllAsRead() async {
    final res = await HttpService.post(
      '${Api.baseUrl}/notifications/read-all',
      {},
      auth: true,
    );

    return res != null;
  }

  // =========================
  // DELETE NOTIFICATION
  // =========================
  static Future<bool> deleteNotification(String notificationId) async {
    final res = await HttpService.delete(
      '${Api.baseUrl}/notifications/$notificationId',
      auth: true,
    );

    return res != null;
  }

  // =========================
  // CLEAR ALL NOTIFICATIONS
  // =========================
  static Future<bool> clearAll() async {
    final res = await HttpService.delete(
      '${Api.baseUrl}/notifications/clear',
      auth: true,
    );

    return res != null;
  }
}

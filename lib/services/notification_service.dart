import '../core/api.dart';
import '../core/http_service.dart';

class NotificationService {
  static Future<List<dynamic>> getAll() async {
    final res = await HttpService.get(Api.notificationsEndpoint);
    return res is List ? res : [];
  }

  static Future<void> markRead(int id) async {
    await HttpService.post(
      '${Api.notificationsEndpoint}/read',
      {'id': id},
    );
  }

  static Future<void> markAllRead() async {
    await HttpService.post(
      '${Api.notificationsEndpoint}/read-all',
      {},
    );
  }
}

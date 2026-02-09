import '../core/http_client.dart';

import 'notifications_service.dart';

class NotificationsRepository {
  NotificationsRepository({HttpClient? client})
      : _service = NotificationsService(client ?? HttpClient());

  final NotificationsService _service;

  Future<List<dynamic>> notifications() => _service.fetchNotifications();
}

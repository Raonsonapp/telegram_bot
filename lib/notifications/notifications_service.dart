import '../core/http_client.dart';

class NotificationsService {
  NotificationsService(this._client);

  final HttpClient _client;

  Future<List<dynamic>> fetchNotifications() async {
    final response = await _client.get('/notifications');
    return List<dynamic>.from(response.data as List);
  }
}

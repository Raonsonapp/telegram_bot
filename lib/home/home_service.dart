import '../core/http_client.dart';

class HomeService {
  HomeService(this._client);

  final HttpClient _client;

  Future<List<dynamic>> fetchFeed() async {
    final response = await _client.get('/feed');
    return List<dynamic>.from(response.data as List);
  }
}

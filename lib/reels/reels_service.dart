import '../core/http_client.dart';

class ReelsService {
  ReelsService(this._client);

  final HttpClient _client;

  Future<List<dynamic>> fetchReels() async {
    final response = await _client.get('/reels');
    return List<dynamic>.from(response.data as List);
  }
}

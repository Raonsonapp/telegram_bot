import '../core/http_client.dart';

class SearchService {
  SearchService(this._client);

  final HttpClient _client;

  Future<List<dynamic>> search(String query) async {
    final response = await _client.get('/search?q=$query');
    return List<dynamic>.from(response.data as List);
  }
}

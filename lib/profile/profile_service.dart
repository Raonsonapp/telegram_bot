import '../core/http_client.dart';

class ProfileService {
  ProfileService(this._client);

  final HttpClient _client;

  Future<Map<String, dynamic>> profile() async {
    final response = await _client.get('/profile');
    return Map<String, dynamic>.from(response.data as Map);
  }
}

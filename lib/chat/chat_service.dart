import '../core/http_client.dart';

class ChatService {
  ChatService(this._client);

  final HttpClient _client;

  Future<List<dynamic>> fetchChats() async {
    final response = await _client.get('/chats');
    return List<dynamic>.from(response.data as List);
  }
}

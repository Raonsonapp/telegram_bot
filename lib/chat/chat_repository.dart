import '../core/http_client.dart';

import 'chat_service.dart';

class ChatRepository {
  ChatRepository({HttpClient? client})
      : _service = ChatService(client ?? HttpClient());

  final ChatService _service;

  Future<List<dynamic>> chats() => _service.fetchChats();
}

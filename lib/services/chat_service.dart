import '../core/api.dart';
import '../core/http_service.dart';

class ChatService {
  static Future<List<dynamic>> getChats() async {
    return await HttpService.get(Api.chatEndpoint);
  }

  static Future<List<dynamic>> getMessages(int chatId) async {
    return await HttpService.get('${Api.chatEndpoint}/$chatId/messages');
  }

  static Future<void> sendMessage(int chatId, String text) async {
    await HttpService.post(
      '${Api.chatEndpoint}/$chatId/send',
      {'text': text},
    );
  }

  static Future<void> createChat(int userId) async {
    await HttpService.post(
      '${Api.chatEndpoint}/create',
      {'user_id': userId},
    );
  }

  static Future<void> markAsRead(int chatId) async {
    await HttpService.post(
      '${Api.chatEndpoint}/$chatId/read',
      {},
    );
  }
}

import '../core/api.dart';
import '../core/http_service.dart';

class ChatService {
  // list of chats
  static Future<List<dynamic>> getChats() async {
    final res = await HttpService.get(Api.chatEndpoint);
    return List<dynamic>.from(res);
  }

  // messages in chat
  static Future<List<dynamic>> getMessages(int chatId) async {
    final res =
        await HttpService.get('${Api.chatEndpoint}/$chatId/messages');
    return List<dynamic>.from(res);
  }

  // send message
  static Future<void> sendMessage(int chatId, String text) async {
    await HttpService.post(
      '${Api.chatEndpoint}/$chatId/send',
      {'text': text},
    );
  }

  // mark as read
  static Future<void> markAsRead(int chatId) async {
    await HttpService.post(
      '${Api.chatEndpoint}/$chatId/read',
      {},
    );
  }
}

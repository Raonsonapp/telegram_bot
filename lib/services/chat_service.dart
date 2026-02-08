import '../core/api.dart';
import '../core/http_service.dart';

class ChatService {
  // ================= GET CHATS =================
  // Рӯйхати чатҳо (dialogs)
  static Future<List<dynamic>> getChats() async {
    final res = await HttpService.get(
      Api.chatEndpoint,
    );
    return res is List ? res : [];
  }

  // ================= CREATE CHAT =================
  // Эҷоди чат бо корбари дигар
  static Future<int?> createChat(String userId) async {
    final res = await HttpService.post(
      '${Api.chatEndpoint}/create',
      {
        'user_id': userId,
      },
    );

    if (res is Map && res['chat_id'] != null) {
      return res['chat_id'];
    }
    return null;
  }

  // ================= GET MESSAGES =================
  // Паёмҳои як чат
  static Future<List<dynamic>> getMessages(int chatId) async {
    final res = await HttpService.get(
      '${Api.chatEndpoint}/$chatId/messages',
    );
    return res is List ? res : [];
  }

  // ================= SEND MESSAGE =================
  // Ирсоли паём
  static Future<void> sendMessage({
    required int chatId,
    required String text,
  }) async {
    await HttpService.post(
      '${Api.chatEndpoint}/$chatId/send',
      {
        'text': text,
      },
    );
  }

  // ================= MARK AS READ =================
  // Қайд кардан ҳамчун хондашуда
  static Future<void> markAsRead(int chatId) async {
    await HttpService.post(
      '${Api.chatEndpoint}/$chatId/read',
      {},
    );
  }

  // ================= DELETE CHAT =================
  // Нест кардани чат (ихтиёрӣ)
  static Future<void> deleteChat(int chatId) async {
    await HttpService.delete(
      '${Api.chatEndpoint}/$chatId',
    );
  }
}

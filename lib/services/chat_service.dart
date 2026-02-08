import '../core/api.dart';
import '../core/http_service.dart';
import '../models/message.dart';
import '../models/user.dart';

class ChatService {
  // ================= CREATE OR GET CHAT =================
  static Future<int?> createChat(int userId) async {
    final res = await HttpService.post(
      '${Api.chatEndpoint}/create',
      {
        'user_id': userId,
      },
    );

    if (res == null || res is! Map) return null;
    return res['chat_id'];
  }

  // ================= GET ALL CHATS =================
  static Future<List<User>> getChats() async {
    final res = await HttpService.get(
      '${Api.chatEndpoint}/list',
    );

    if (res == null || res is! List) return [];

    return res.map<User>((e) => User.fromJson(e)).toList();
  }

  // ================= GET MESSAGES =================
  static Future<List<Message>> getMessages(int chatId) async {
    final res = await HttpService.get(
      '${Api.chatEndpoint}/$chatId/messages',
    );

    if (res == null || res is! List) return [];

    return res.map<Message>((e) => Message.fromJson(e)).toList();
  }

  // ================= SEND MESSAGE =================
  static Future<Message?> sendMessage({
    required int chatId,
    required String text,
  }) async {
    final res = await HttpService.post(
      '${Api.chatEndpoint}/$chatId/send',
      {
        'text': text,
      },
    );

    if (res == null || res is! Map) return null;

    return Message.fromJson(res);
  }

  // ================= MARK AS READ =================
  static Future<void> markAsRead(int chatId) async {
    await HttpService.post(
      '${Api.chatEndpoint}/$chatId/read',
      {},
    );
  }
}

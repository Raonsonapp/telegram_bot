import '../core/api.dart';
import '../core/http_service.dart';
import '../models/message.dart';
import '../models/user.dart';

class ChatService {
  // ================= GET CHATS =================
  static Future<List<UserModel>> getChats() async {
    final response = await HttpService.get(
      Api.chatEndpoint,
    );

    return (response as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  // ================= GET MESSAGES =================
  static Future<List<MessageModel>> getMessages(int userId) async {
    final response = await HttpService.get(
      '${Api.chatEndpoint}/$userId/messages',
    );

    return (response as List)
        .map((json) => MessageModel.fromJson(json))
        .toList();
  }

  // ================= SEND MESSAGE =================
  static Future<MessageModel> sendMessage({
    required int toUserId,
    required String text,
  }) async {
    final response = await HttpService.post(
      '${Api.chatEndpoint}/send',
      {
        'to_user_id': toUserId,
        'text': text,
      },
    );

    return MessageModel.fromJson(response);
  }

  // ================= MARK AS READ =================
  static Future<void> markAsRead(int userId) async {
    await HttpService.post(
      '${Api.chatEndpoint}/$userId/read',
      {},
    );
  }

  // ================= CREATE CHAT (OPTIONAL) =================
  static Future<void> createChat(int userId) async {
    await HttpService.post(
      '${Api.chatEndpoint}/create',
      {
        'user_id': userId,
      },
    );
  }
}

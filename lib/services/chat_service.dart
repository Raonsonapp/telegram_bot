/// lib/services/chat_service.dart
/// =====================================================
/// CHAT SERVICE – FINAL v5 (FIXED)
/// Handles:
/// - Chat list
/// - Chat messages
/// - Send message
/// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/message.dart';

class ChatService {
  // =====================================================
  // GET CHAT LIST
  // =====================================================
  /// GET /chats
  static Future<List<Map<String, dynamic>>> getChats() async {
    final res = await HttpService.get(
      Api.chatList,
      auth: true,
    );

    if (res is List) {
      return List<Map<String, dynamic>>.from(res);
    }

    return [];
  }

  // =====================================================
  // GET MESSAGES BY CHAT ID
  // =====================================================
  /// GET /chats/{chatId}
  static Future<List<Message>> getMessages(int chatId) async {
    final res = await HttpService.get(
      Api.chatMessages(chatId),
      auth: true,
    );

    if (res is List) {
      return res
          .map<Message>((e) => Message.fromJson(e))
          .toList();
    }

    return [];
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================
  /// POST /chats/{chatId}/send
  static Future<Message> sendMessage({
    required int chatId,
    required String text,
  }) async {
    final res = await HttpService.post(
      Api.sendMessage(chatId),
      body: {
        'text': text,
      },
      auth: true,
    );

    return Message.fromJson(res);
  }

  // =====================================================
  // DELETE CHAT
  // =====================================================
  /// DELETE /chats/{chatId}
  static Future<void> deleteChat(int chatId) async {
    await HttpService.delete(
      Api.chatMessages(chatId),
      auth: true,
    );
  }
}

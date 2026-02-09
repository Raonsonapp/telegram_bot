// lib/services/chat_service.dart

import 'dart:convert';
import '../core/api.dart';
import '../core/http_service.dart';
import '../core/session.dart';
import '../models/message.dart';

class ChatService {
  // =========================
  // GET ALL CHATS (CHAT LIST)
  // =========================
  static Future<List<dynamic>> getChats() async {
    final token = await Session.getToken();

    final res = await HttpService.get(
      Api.chats,
      auth: true,
    );

    if (res is List) {
      return res;
    }

    return [];
  }

  // =========================
  // CREATE / OPEN CHAT
  // =========================
  static Future<Map<String, dynamic>?> createChat({
    required String userId,
  }) async {
    final res = await HttpService.post(
      Api.chats,
      {
        'user_id': userId,
      },
      auth: true,
    );

    if (res is Map<String, dynamic>) {
      return res;
    }

    return null;
  }

  // =========================
  // GET MESSAGES BY CHAT ID
  // =========================
  static Future<List<Message>> getMessages(String chatId) async {
    final res = await HttpService.get(
      '${Api.messages}/$chatId',
      auth: true,
    );

    if (res is List) {
      return res.map((e) => Message.fromJson(e)).toList();
    }

    return [];
  }

  // =========================
  // SEND MESSAGE
  // =========================
  static Future<Message?> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final res = await HttpService.post(
      Api.sendMessage,
      {
        'chat_id': chatId,
        'text': text,
      },
      auth: true,
    );

    if (res is Map<String, dynamic>) {
      return Message.fromJson(res);
    }

    return null;
  }

  // =========================
  // MARK MESSAGES AS READ
  // =========================
  static Future<bool> markAsRead(String chatId) async {
    final res = await HttpService.post(
      '${Api.messages}/$chatId/read',
      {},
      auth: true,
    );

    return res != null;
  }

  // =========================
  // DELETE CHAT (OPTIONAL)
  // =========================
  static Future<bool> deleteChat(String chatId) async {
    final res = await HttpService.delete(
      '${Api.chats}/$chatId',
      auth: true,
    );

    return res != null;
  }
}

/// lib/core/socket_service.dart
/// =====================================================
/// SOCKET SERVICE – FINAL v5
/// Central real-time layer for Raonson App
/// =====================================================

import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'api.dart';
import 'session.dart';

class SocketService {
  SocketService._();

  static IO.Socket? _socket;
  static bool _isConnected = false;

  // =====================================================
  // INIT & CONNECT
  // =====================================================

  static Future<void> connect() async {
    if (_isConnected) return;

    final token = Session.getToken();
    if (token == null || token.isEmpty) return;

    _socket = IO.io(
      Api.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      print('🟢 Socket connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('🔴 Socket disconnected');
    });

    _socket!.onConnectError((e) {
      print('❌ Socket connect error: $e');
    });
  }

  // =====================================================
  // DISCONNECT
  // =====================================================

  static void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
  }

  // =====================================================
  // CHAT EVENTS
  // =====================================================

  static void sendMessage({
    required String chatId,
    required String message,
  }) {
    if (!_isConnected) return;

    _socket!.emit('send_message', {
      'chat_id': chatId,
      'message': message,
    });
  }

  static void sendTyping({
    required String chatId,
    required bool typing,
  }) {
    if (!_isConnected) return;

    _socket!.emit('typing', {
      'chat_id': chatId,
      'typing': typing,
    });
  }

  // =====================================================
  // LISTENERS
  // =====================================================

  static void onNewMessage(void Function(dynamic data) callback) {
    _socket?.on('new_message', callback);
  }

  static void onTyping(void Function(dynamic data) callback) {
    _socket?.on('typing', callback);
  }

  static void onUserOnline(void Function(dynamic data) callback) {
    _socket?.on('user_online', callback);
  }

  static void onUserOffline(void Function(dynamic data) callback) {
    _socket?.on('user_offline', callback);
  }

  // =====================================================
  // CLEANUP
  // =====================================================

  static void removeAllListeners() {
    if (_socket == null) return;

    _socket!.off('new_message');
    _socket!.off('typing');
    _socket!.off('user_online');
    _socket!.off('user_offline');
  }

  static bool get isConnected => _isConnected;
}

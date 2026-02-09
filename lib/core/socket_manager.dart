/// =====================================================
/// SOCKET MANAGER – RAONSON CORE
/// Handles realtime communication (WebSocket / Socket.IO)
/// =====================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'token_storage.dart';
import 'api.dart';

typedef SocketCallback = void Function(dynamic data);

class SocketManager {
  SocketManager._();

  static WebSocket? _socket;
  static bool _connecting = false;

  static final Map<String, List<SocketCallback>> _listeners = {};

  static Timer? _pingTimer;

  // ================= CONNECT =================
  static Future<void> connect() async {
    if (_socket != null || _connecting) return;
    _connecting = true;

    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) return;

      final uri = Uri.parse('${Api.socket}?token=$token');

      _socket = await WebSocket.connect(uri.toString());
      _connecting = false;

      _socket!.listen(
        _onMessage,
        onDone: _onDisconnect,
        onError: (_) => _onDisconnect(),
      );

      _startPing();
    } catch (_) {
      _connecting = false;
      _scheduleReconnect();
    }
  }

  // ================= DISCONNECT =================
  static Future<void> disconnect() async {
    _pingTimer?.cancel();
    _pingTimer = null;

    await _socket?.close();
    _socket = null;
    _listeners.clear();
  }

  // ================= SEND =================
  static void emit(String event, dynamic data) {
    if (_socket == null) return;

    final payload = jsonEncode({
      'event': event,
      'data': data,
    });

    _socket!.add(payload);
  }

  // ================= LISTEN =================
  static void on(String event, SocketCallback callback) {
    _listeners.putIfAbsent(event, () => []);
    _listeners[event]!.add(callback);
  }

  static void off(String event, [SocketCallback? callback]) {
    if (!_listeners.containsKey(event)) return;

    if (callback == null) {
      _listeners.remove(event);
    } else {
      _listeners[event]!.remove(callback);
    }
  }

  // ================= INTERNAL =================
  static void _onMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message);
      final String event = decoded['event'];
      final data = decoded['data'];

      if (_listeners.containsKey(event)) {
        for (final cb in _listeners[event]!) {
          cb(data);
        }
      }
    } catch (_) {
      // ignore malformed packets
    }
  }

  static void _onDisconnect() {
    _socket = null;
    _pingTimer?.cancel();
    _scheduleReconnect();
  }

  static void _scheduleReconnect() {
    Future.delayed(const Duration(seconds: 3), connect);
  }

  // ================= KEEP ALIVE =================
  static void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(
      const Duration(seconds: 25),
      (_) {
        emit('ping', {'t': DateTime.now().toIso8601String()});
      },
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import 'api.dart';
import 'session_manager.dart';
import 'error_handler.dart';

/// SocketManager
/// ------------------------------------------------------------
/// - Handles realtime connection (chat, typing, online status)
/// - Auto reconnect with backoff
/// - Auth via token
/// - Event-based messaging
///
/// Compatible with FastAPI / WebSocket backend
class SocketManager {
  SocketManager._internal();
  static final SocketManager instance = SocketManager._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final StreamController<Map<String, dynamic>> _eventsController =
      StreamController.broadcast();

  bool _connecting = false;
  bool _connected = false;

  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  /// Public stream of socket events
  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  bool get isConnected => _connected;

  // ===========================================================
  // CONNECT
  // ===========================================================
  Future<void> connect() async {
    if (_connecting || _connected) return;

    _connecting = true;

    try {
      final token = await SessionManager.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Socket token missing');
      }

      final uri = Uri.parse(
        '${Api.wsBaseUrl}?token=$token',
      );

      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: true,
      );

      _connected = true;
      _connecting = false;
      _reconnectAttempts = 0;

      _emitSystem('connected');
    } catch (e, s) {
      _connecting = false;
      ErrorHandler.capture(e, s);
      _scheduleReconnect();
    }
  }

  // ===========================================================
  // DISCONNECT
  // ===========================================================
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _connected = false;
    _connecting = false;

    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close(ws_status.goingAway);
    _channel = null;

    _emitSystem('disconnected');
  }

  // ===========================================================
  // SEND EVENT
  // ===========================================================
  void send(String type, Map<String, dynamic> payload) {
    if (!_connected || _channel == null) return;

    final data = jsonEncode({
      'type': type,
      'payload': payload,
    });

    _channel!.sink.add(data);
  }

  // ===========================================================
  // INTERNAL: MESSAGE HANDLER
  // ===========================================================
  void _onMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message as String);

      if (decoded is Map<String, dynamic>) {
        _eventsController.add(decoded);
      }
    } catch (e, s) {
      ErrorHandler.capture(e, s);
    }
  }

  // ===========================================================
  // INTERNAL: ERROR
  // ===========================================================
  void _onError(Object error) {
    _connected = false;
    ErrorHandler.capture(error);
    _scheduleReconnect();
  }

  // ===========================================================
  // INTERNAL: DONE
  // ===========================================================
  void _onDone() {
    _connected = false;
    _emitSystem('closed');
    _scheduleReconnect();
  }

  // ===========================================================
  // RECONNECT LOGIC
  // ===========================================================
  void _scheduleReconnect() {
    if (_reconnectTimer != null) return;

    _reconnectAttempts++;
    final delay = Duration(
      seconds: (_reconnectAttempts.clamp(1, 6)) * 2,
    );

    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      connect();
    });
  }

  // ===========================================================
  // SYSTEM EVENTS
  // ===========================================================
  void _emitSystem(String event) {
    _eventsController.add({
      'type': 'system',
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ===========================================================
  // CLEANUP
  // ===========================================================
  void dispose() {
    disconnect();
    _eventsController.close();
  }
}

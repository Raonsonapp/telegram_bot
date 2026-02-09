import 'package:socket_io_client/socket_io_client.dart' as io;

import 'api.dart';

class SocketManager {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect({String? token}) {
    _socket = io.io(
      ApiConfig.baseUrl,
      io.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
        if (token != null) 'Authorization': 'Bearer $token',
      }).build(),
    );
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}

import 'package:flutter/foundation.dart';

import '../../models/message_model.dart';
import 'chat_room_state.dart';

class ChatRoomController extends ChangeNotifier {
  ChatRoomController()
      : _state = ChatRoomState(messages: _mockMessages());

  ChatRoomState _state;

  ChatRoomState get state => _state;

  static List<MessageModel> _mockMessages() {
    return [
      MessageModel(id: '1', username: 'me', lastMessage: 'Salom!'),
      MessageModel(id: '2', username: 'ardamehr', lastMessage: 'Bro?'),
    ];
  }
}

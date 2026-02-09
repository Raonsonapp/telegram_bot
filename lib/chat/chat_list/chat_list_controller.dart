import 'package:flutter/foundation.dart';

import '../../models/message_model.dart';
import '../chat_repository.dart';
import 'chat_list_state.dart';

class ChatListController extends ChangeNotifier {
  ChatListController(this._repository)
      : _state = ChatListState(items: const [], loading: true) {
    load();
  }

  final ChatRepository _repository;
  ChatListState _state;

  ChatListState get state => _state;

  Future<void> load() async {
    try {
      final response = await _repository.chats();
      _state = ChatListState(
        items: response
            .map((item) => MessageModel.fromMap(item as Map<String, dynamic>))
            .toList(),
        loading: false,
      );
    } catch (_) {
      _state = ChatListState(items: _fallbackMessages(), loading: false);
    }
    notifyListeners();
  }

  List<MessageModel> _fallbackMessages() {
    return [
      MessageModel(
        id: '1',
        username: 'ardamehr',
        lastMessage: 'Bro?',
        timeAgo: '3 h',
      ),
      MessageModel(
        id: '2',
        username: 'mehrat',
        lastMessage: 'Tomorrow is exam?',
        timeAgo: '7 h',
      ),
    ];
  }
}

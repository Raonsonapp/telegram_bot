import '../../models/message_model.dart';

class ChatListState {
  ChatListState({required this.items, this.loading = false});

  final List<MessageModel> items;
  final bool loading;
}

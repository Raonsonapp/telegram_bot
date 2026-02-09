import '../../models/message_model.dart';

class ChatRoomState {
  ChatRoomState({required this.messages});

  final List<MessageModel> messages;
}

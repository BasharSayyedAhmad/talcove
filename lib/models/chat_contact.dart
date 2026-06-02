// models/chat_contact.dart
import 'package:talcove/models/message.dart';
import 'package:talcove/models/user.dart';

class ChatContact {
  final User user;
  final Message? lastMessage;
  final DateTime lastMessageTime;

  ChatContact({
    required this.user,
    this.lastMessage,
    required this.lastMessageTime,
  });
}

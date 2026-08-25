import 'package:talcove/models/message.dart';
import 'package:talcove/models/user.dart';

class ChatContact {
  final User user;
  final Message? lastMessage;
  final DateTime lastMessageTime;
  final int? unreadCount;
  ChatContact({
    required this.user,
    this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
  ChatContact copyWith({
    User? user,
    Message? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatContact(
      user: user ?? this.user,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

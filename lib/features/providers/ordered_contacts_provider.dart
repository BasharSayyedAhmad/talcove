import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/features/providers/chat_provider.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
import 'package:talcove/models/chat_contact.dart';
import 'package:talcove/models/message.dart';
import 'package:talcove/models/user.dart';

part 'ordered_contacts_provider.g.dart';

@riverpod
class OrderedContactsNotifier extends _$OrderedContactsNotifier {
  @override
  List<ChatContact> build() {
    final contacts = ref.watch(contactsNotifierProvider);
    final messages = ref.watch(messageNotifierProvider);
    return _computeOrderedContacts(contacts, messages);
  }

  List<ChatContact> _computeOrderedContacts(
    List<User> contacts,
    List<Message> messages,
  ) {
    final Map<String, ChatContact> contactMap = {};

    for (final user in contacts) {
      contactMap[user.userName] = ChatContact(
        user: user,
        lastMessage: null,
        lastMessageTime: DateTime(2000),
      );
    }

    // تحديث آخر رسالة لكل مستخدم من قائمة الرسائل
    for (final message in messages) {
      final otherName = message.isMe ? message.receiverId : message.senderId;
      final existing = contactMap[otherName];
      if (existing != null) {
        if (existing.lastMessageTime.isBefore(message.timestamp)) {
          contactMap[otherName] = ChatContact(
            user: existing.user,
            lastMessage: message,
            lastMessageTime: message.timestamp,
          );
        }
      }
    }

    final ordered = contactMap.values.toList();
    ordered.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    return ordered;
  }
}

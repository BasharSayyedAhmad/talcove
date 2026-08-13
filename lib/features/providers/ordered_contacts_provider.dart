import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/features/providers/chat_list_provider.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
import 'package:talcove/models/chat_contact.dart';
import 'package:talcove/models/message.dart';
import 'package:talcove/models/user.dart';

part 'ordered_contacts_provider.g.dart';

@riverpod
class OrderedContactsNotifier extends _$OrderedContactsNotifier {
  final Map<String, int> _unreadCounts = {};

  @override
  List<ChatContact> build() {
    final contacts = ref.watch(contactsNotifierProvider);
    final lastMessagesMap = ref.watch(chatListNotifierProvider);
    final currentUserId = ref.watch(authNotifierProvider).user?.id ?? '';

    return _computeOrderedContacts(contacts, lastMessagesMap, currentUserId);
  }

  List<ChatContact> _computeOrderedContacts(
    List<User> contacts,
    Map<String, Message> lastMessagesMap,
    String currentUserId,
  ) {
    final List<ChatContact> orderedList = [];
    final Set<String> processedUserIds = {};

    for (final user in contacts) {
      final lastMsg = lastMessagesMap[user.id];
      processedUserIds.add(user.id);

      orderedList.add(
        ChatContact(
          user: user,
          lastMessage: lastMsg,
          lastMessageTime: lastMsg?.timestamp ?? DateTime(2000),
          unreadCount: _unreadCounts[user.id] ?? 0,
        ),
      );
    }

    for (final entry in lastMessagesMap.entries) {
      final contactId = entry.key;
      final lastMsg = entry.value;

      if (!processedUserIds.contains(contactId)) {
        final isMe = lastMsg.senderId == currentUserId;

        final dynamicUser = User(
          id: contactId,
          userName: isMe ? "Me" : "User $contactId",
          photoUrl: null,
          email: '',
        );

        orderedList.add(
          ChatContact(
            user: dynamicUser,
            lastMessage: lastMsg,
            lastMessageTime: lastMsg.timestamp,
            unreadCount: _unreadCounts[contactId] ?? 0,
          ),
        );
      }
    }

    orderedList.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return orderedList;
  }

  void incrementUnread(String senderId) {
    _unreadCounts[senderId] = (_unreadCounts[senderId] ?? 0) + 1;

    state = state.map((contact) {
      if (contact.user.id == senderId) {
        return contact.copyWith(unreadCount: _unreadCounts[senderId]);
      }
      return contact;
    }).toList();
  }

  void markAsRead(String userId) {
    _unreadCounts[userId] = 0;

    state = state.map((contact) {
      if (contact.user.id == userId) {
        return contact.copyWith(unreadCount: 0);
      }
      return contact;
    }).toList();
  }
}

@riverpod
int totalUnreadMessages(Ref ref) {
  final contacts = ref.watch(orderedContactsNotifierProvider);
  return contacts.fold<int>(
    0,
    (sum, contact) => sum + (contact.unreadCount ?? 0),
  );
}

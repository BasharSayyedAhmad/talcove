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
        ),
      );
    }

    for (final entry in lastMessagesMap.entries) {
      final contactId = entry.key;
      final lastMsg = entry.value;

      // إذا الشخص مو معالج مسبقاً بالـ contacts، بنضيفه فوراً كـ Dynamic Contact
      if (!processedUserIds.contains(contactId)) {
        // تحديد من هو المرسل الحقيقي بناءً على الـ ID
        final isMe = lastMsg.senderId == currentUserId;

        // بناء كائن مستخدم مؤقت طالما الداتا لسا ما إجت كاملة من الـ API
        final dynamicUser = User(
          id: contactId,
          userName: isMe
              ? "Me"
              : "User $contactId", // أو اسم افتراضي لحين جلب البيانات
          photoUrl: null,
          email: '',
        );

        orderedList.add(
          ChatContact(
            user: dynamicUser,
            lastMessage: lastMsg,
            lastMessageTime: lastMsg.timestamp,
          ),
        );
      }
    }

    // ترتيب القائمة تنازلياً: الأحدث دايماً فوق
    orderedList.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return orderedList;
  }
}

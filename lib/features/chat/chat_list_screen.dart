import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/chat/chat_screen.dart';
import 'package:talcove/features/people/search_screen.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
import 'package:talcove/features/providers/ordered_contacts_provider.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/shared/widgets/custom_text.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // ✅ القائمة الأفقية (تبقى كما هي - من ContactsProvider)
    final contacts = ref.watch(contactsNotifierProvider);
    final displayedContacts = contacts.take(20).toList();
    print("🔄 ChatListScreen rebuilt - Total contacts: ${contacts.length}");
    for (var c in contacts) {
      print("   - ${c.userName} (${c.id})");
    }
    // ✅ القائمة العمودية (مرتبة حسب آخر رسالة)
    final orderedContacts = ref.watch(orderedContactsNotifierProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(
          top: 50,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        children: [
          // حقل البحث
          CustomText(
            controller: searchController,
            hintText: S.of(context).searchConversations,
            prefixIcon: const Icon(Icons.search),
          ),

          const SizedBox(height: 10),

          // عنوان الأشخاص
          Text(
            S.of(context).people,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // ✅ القائمة الأفقية (تبقى كما هي - لا تتغير)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayedContacts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  );
                }

                final user = displayedContacts[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: "",
                            otherUserId: user.userName,
                            otherUserName: user.userName,
                            otherUserPhoto: user.photoUrl,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  user.userName.isNotEmpty
                                      ? user.userName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontSize: 24),
                                )
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.userName.length > 10
                              ? '${user.userName.substring(0, 10)}...'
                              : user.userName,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ✅ عنوان المحادثات
          const Text(
            "Chats",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // ✅ القائمة العمودية (جديدة - المحادثات مرتبة حسب آخر رسالة)
          if (orderedContacts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text("No conversations yet"),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true, // ✅ مهم لتجنب مشاكل الـ Infinite height
              physics:
                  const NeverScrollableScrollPhysics(), // ✅ لأنها داخل ListView
              itemCount: orderedContacts.length,
              itemBuilder: (context, index) {
                final contact = orderedContacts[index];
                final user = contact.user;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(user.userName[0].toUpperCase())
                        : null,
                  ),
                  title: Text(user.userName),
                  subtitle: Text(
                    contact.lastMessage?.text ?? 'Start a conversation',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(_formatTime(contact.lastMessageTime)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatId: "",
                          otherUserId: user.userName,
                          otherUserName: user.userName,
                          otherUserPhoto: user.photoUrl,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

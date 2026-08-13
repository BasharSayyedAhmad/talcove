import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/core/services/user_service.dart';
import 'package:talcove/features/chat/chat_screen.dart';
import 'package:talcove/features/people/search_screen.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/features/providers/chat_list_provider.dart';
import 'package:talcove/features/providers/chat_provider.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
import 'package:talcove/features/providers/ordered_contacts_provider.dart';
import 'package:talcove/generated/l10n.dart';

import 'package:talcove/shared/services/socket_service.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  late final SocketService _socketService;
  Timer? _pollingTimer;

  Future<void> _syncContacts() async {
    try {
      final contacts = await UserService().fetchUserContacts();

      if (contacts.isNotEmpty && mounted) {
        ref.read(contactsNotifierProvider.notifier).setContacts(contacts);
      }
    } catch (e) {
      print("❌ Error syncing contacts: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncContacts();
      _connectSocketIfNeeded();
      _startPolling();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _connectSocketIfNeeded() async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.user;
    final userId = user?.id;

    if (userId != null) {
      try {
        final token = user?.token ?? ApiService().accessToken;

        if (token != null && !_socketService.isConnected) {
          ref
              .read(messageNotifierProvider.notifier)
              .connectSocket(userId, token);
        }
      } catch (e) {
        debugPrint("❌ Error getting dynamic token: $e");
      }

      _fetchLastMessages();
    }
  }

  Future<void> _fetchLastMessages() async {
    if (!mounted) return;

    final contacts = ref.read(contactsNotifierProvider);
    if (contacts.isEmpty) return;

    final contactIds = contacts.map((c) => c.id).toList();

    await ref
        .read(chatListNotifierProvider.notifier)
        .fetchLastMessages(contactIds);
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _fetchLastMessages();
      }
    });
  }

  void _navigateToChat(String userId, String userName, String? photoUrl) {
    ref.read(chatListNotifierProvider.notifier).markAsRead(userId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: "",
          otherUserId: userId,
          otherUserName: userName,
          otherUserPhoto: photoUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // الاستماع لتغيرات جهات الاتصال لجلب أحدث الرسائل
    ref.listen(contactsNotifierProvider, (previous, next) {
      if ((previous == null || previous.isEmpty) && next.isNotEmpty) {
        _fetchLastMessages();
      }
    });

    final contacts = ref.watch(contactsNotifierProvider);
    final displayedContacts = contacts.take(20).toList();
    final authState = ref.watch(authNotifierProvider);
    final isConnected = authState.hasInternet;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chatMap = ref.watch(chatListNotifierProvider);
    final orderedContacts = ref.watch(orderedContactsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: !isConnected
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(S.of(context).connecting),
                ],
              )
            : const Text("Talcove"),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: !isDark
                  ? [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                    ]
                  : const [
                      Color.fromARGB(255, 26, 35, 126),
                      Color.fromARGB(255, 57, 73, 171),
                    ],
            ),
          ),
        ),
        actions: [
          if (authState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(),
                ),
              ),
            ),
          if (!authState.hasInternet)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.wifi_off,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchLastMessages();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).people,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                                  maxRadius: 25,
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
                              onTap: () => _navigateToChat(
                                user.id,
                                user.userName,
                                user.photoUrl,
                              ),
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
                                            style: const TextStyle(
                                              fontSize: 24,
                                            ),
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
                    const SizedBox(height: 10),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            if (orderedContacts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(S.of(context).noConversationsYet)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final contact = orderedContacts[index];
                    final user = contact.user;

                    final lastMsg = chatMap[user.id] ?? contact.lastMessage;
                    final unreadCount = lastMsg?.unreadCount ?? 0;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: CircleAvatar(
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.userName.isNotEmpty
                                    ? user.userName[0].toUpperCase()
                                    : '?',
                              )
                            : null,
                      ),
                      title: Text(user.userName),
                      subtitle: Text(
                        lastMsg?.text ?? S.of(context).startAConversation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(contact.lastMessageTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: unreadCount > 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      onTap: () => _navigateToChat(
                        user.id,
                        user.userName,
                        user.photoUrl,
                      ),
                    );
                  }, childCount: orderedContacts.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final now = DateTime.now();
  final localTime = time.toLocal();
  final diff = now.difference(localTime);

  if (diff.inDays >= 7) {
    return '${localTime.day}/${localTime.month}';
  } else if (diff.inDays >= 1) {
    return '${diff.inDays}d';
  } else if (diff.inHours >= 1) {
    return '${diff.inHours}h';
  } else if (diff.inMinutes >= 1) {
    return '${diff.inMinutes}m';
  } else {
    return 'now';
  }
}

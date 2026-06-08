import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/chat/chat_screen.dart';
import 'package:talcove/features/people/search_screen.dart';
import 'package:talcove/features/providers/auth_provider.dart';
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
  final TextEditingController searchController = TextEditingController();
  late final SocketService _socketService;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectSocketIfNeeded();
      _startPolling();
    });

    //  FIX: حذف _listenToNewMessages() بالكامل
    // MessageNotifier._setupSocketListeners() هو الوحيد اللي يستمع للـ socket
    // orderedContactsNotifierProvider يراقب messageNotifierProvider تلقائياً
    // وبالتالي ChatListScreen بيتحدث عبر ref.watch بدون أي listener إضافي
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _connectSocketIfNeeded() {
    final authState = ref.read(authNotifierProvider);
    final user = authState.user;
    final token = user?.token;
    final userId = user?.id;

    if (token != null && userId != null) {
      if (!_socketService.isConnected) {
        print("🔄 Reconnecting socket...");
        ref.read(messageNotifierProvider.notifier).connectSocket(userId, token);
      }

      // عند كل فتح للشاشة، جيب آخر رسالة لكل contact
      // هيك القائمة تتعبى حتى بدون ما تفتح أي محادثة
      _fetchLastMessages();
    }
  }

  Future<void> _fetchLastMessages() async {
    // انتظر شوية مشان الـ contacts يتحملوا أول
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final contacts = ref.read(contactsNotifierProvider);
    if (contacts.isEmpty) return;

    final contactIds = contacts.map((c) => c.id).toList();
    await ref
        .read(messageNotifierProvider.notifier)
        .fetchLastMessageForContacts(contactIds);
  }

  void _startPolling() {
    //  FIX: استخدام _pollingTimer المعرّف في الـ state بدل Timer.periodic المفقود
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        ref.read(messageNotifierProvider.notifier).fetchNewMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsNotifierProvider);
    final displayedContacts = contacts.take(20).toList();
    final authState = ref.watch(authNotifierProvider);
    final isConnected = authState.hasInternet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    print(" UI - hasInternet: $isConnected");
    //  لما الـ contacts يتحملوا لأول مرة، جيب اخر رسالة لكلهم
    ref.listen(contactsNotifierProvider, (previous, next) {
      if ((previous == null || previous.isEmpty) && next.isNotEmpty) {
        _fetchLastMessages();
      }
    });

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
      body: ListView(
        padding: const EdgeInsets.only(
          top: 20,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        children: [
          const SizedBox(height: 10),
          Text(
            S.of(context).people,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: "",
                            otherUserId: user.id,
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
          Divider(
            height: 1,
            indent: 0,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          if (orderedContacts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(S.of(context).noConversationsYet),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                    contact.lastMessage?.text ??
                        S.of(context).startAConversation,
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
                          otherUserId: user.id,
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

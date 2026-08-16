import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
import 'package:talcove/models/message.dart';
import 'package:talcove/models/user.dart';
import 'package:talcove/shared/services/local_storage_service.dart';
import 'package:talcove/shared/services/socket_service.dart';

part 'chat_list_provider.g.dart';

@riverpod
class ChatListNotifier extends _$ChatListNotifier {
  final ApiService _apiService = ApiService();
  String? _currentUserId;
  bool _isFetching = false;
  bool _isSocketListening = false;

  @override
  Map<String, Message> build() {
    final authState = ref.watch(authNotifierProvider);
    _currentUserId = authState.user?.id;

    if (_currentUserId != null && !_isSocketListening) {
      _isSocketListening = true;

      SocketService().onNewMessage((data) {
        try {
          final mapData = data;
          final senderId = mapData['senderId'] ?? "";
          final receiverId = mapData['receiverId'] ?? "";

          if (senderId != _currentUserId && receiverId != _currentUserId) {
            return;
          }

          final bool isMe = (senderId == _currentUserId);

          final newMessage = Message(
            id: mapData['_id'] ?? DateTime.now().toString(),
            text: mapData['message'] ?? "",
            senderId: senderId,
            receiverId: receiverId,
            isMe: isMe,
            timestamp: mapData['createdAt'] != null
                ? DateTime.parse(mapData['createdAt'])
                : DateTime.now(),
            isSent: true,
            isDelivered: mapData['delivered'] ?? true,
            isRead: false,
          );

          final contactId = isMe ? receiverId : senderId;
          final rawPartnerName = isMe
              ? (mapData['receiverUserName'] ?? '')
              : (mapData['senderUserName'] ?? '');

          final contactsNotifier = ref.read(contactsNotifierProvider.notifier);
          final existingContact = contactsNotifier.getContactById(contactId);

          if (existingContact == null) {
            final String fallbackName =
                "User_${contactId.length >= 4 ? contactId.substring(contactId.length - 4) : contactId}";
            final String finalUserName =
                (rawPartnerName.toString().trim().isNotEmpty)
                ? rawPartnerName.toString()
                : fallbackName;

            final newUser = User(
              id: contactId,
              userName: finalUserName,
              photoUrl: null,
              email: '',
            );
            contactsNotifier.addContact(newUser);
          }

          addOrUpdateContact(
            contactId: contactId,
            lastMessage: newMessage,
            incrementUnread: !isMe,
          );
        } catch (e) {
          print("Error parsing socket message in ChatListNotifier: $e");
        }
      });
    }

    ref.onDispose(() {
      _isSocketListening = false;
    });

    return _loadChatMapFromHive();
  }

  void clear() {
    state = {};
  }

  Map<String, dynamic> _chatMapToJson(Map<String, Message> chatMap) {
    return chatMap.map(
      (contactId, msg) => MapEntry(contactId, {
        'id': msg.id,
        'text': msg.text,
        'senderId': msg.senderId,
        'receiverId': msg.receiverId,
        'isMe': msg.isMe,
        'timestamp': msg.timestamp.toIso8601String(),
        'isSent': msg.isSent,
        'isDelivered': msg.isDelivered,
        'isRead': msg.isRead,
        'unreadCount': msg.unreadCount,
      }),
    );
  }

  Map<String, Message> _loadChatMapFromHive() {
    if (_currentUserId == null) return {};
    try {
      final box = LocalStorageService.box;
      final Map<dynamic, dynamic>? rawMap = box.get(
        'chat_list_$_currentUserId',
      );

      if (rawMap == null) return {};

      final Map<String, Message> resultMap = {};
      rawMap.forEach((key, value) {
        final json = Map<String, dynamic>.from(value);
        resultMap[key.toString()] = Message(
          id: json['id'] ?? '',
          text: json['text'] ?? '',
          senderId: json['senderId'] ?? '',
          receiverId: json['receiverId'] ?? '',
          isMe: json['isMe'] ?? false,
          timestamp: json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
          isSent: json['isSent'] ?? true,
          isDelivered: json['isDelivered'] ?? true,
          isRead: json['isRead'] ?? false,
          unreadCount: json['unreadCount'] ?? 0,
        );
      });

      return resultMap;
    } catch (e) {
      print("Error loading cached chats from LocalStorageService: $e");
      return {};
    }
  }

  void _saveChatMapToHive(Map<String, Message> chatMap) {
    if (_currentUserId == null) return;
    try {
      final box = LocalStorageService.box;
      box.put('chat_list_$_currentUserId', _chatMapToJson(chatMap));
    } catch (e) {
      print("Error saving chats to LocalStorageService: $e");
    }
  }

  Future<void> fetchNewMessages() async {
    if (_currentUserId == null) return;

    try {
      final response = await _apiService.dio.get('/api/v1/messages/new');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> newMessagesJson =
            response.data['data']['newMessages'] ?? [];

        if (newMessagesJson.isEmpty) return;

        final contactsNotifier = ref.read(contactsNotifierProvider.notifier);

        for (var json in newMessagesJson) {
          final senderData = json['senderId'];
          final String senderId = (senderData is Map)
              ? (senderData['_id'] ?? '').toString()
              : (senderData ?? '').toString();
          final String senderUserName = (senderData is Map)
              ? (senderData['userName'] ?? '').toString()
              : '';
          final receiverData = json['receiverId'];
          final String receiverId = (receiverData is Map)
              ? (receiverData['_id'] ?? '').toString()
              : (receiverData ?? '').toString();
          final String receiverUserName = (receiverData is Map)
              ? (receiverData['userName'] ?? '').toString()
              : '';

          final bool isMe = (senderId == _currentUserId);

          final msg = Message(
            id: (json['_id'] ?? DateTime.now().toString()).toString(),
            text: json['message'] ?? "",
            senderId: senderId,
            receiverId: receiverId,
            isMe: isMe,
            timestamp: json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now(),
            isSent: true,
            isDelivered: json['delivered'] ?? true,
            isRead: false,
          );

          final contactId = isMe ? receiverId : senderId;
          final partnerUserName = isMe ? receiverUserName : senderUserName;

          if (contactsNotifier.getContactById(contactId) == null) {
            final String fallbackName =
                "User_${contactId.length >= 4 ? contactId.substring(contactId.length - 4) : contactId}";
            final String finalUserName = partnerUserName.trim().isNotEmpty
                ? partnerUserName
                : fallbackName;

            final newUser = User(
              id: contactId,
              userName: finalUserName,
              photoUrl: null,
              email: '',
            );
            contactsNotifier.addContact(newUser);
          }

          addOrUpdateContact(
            contactId: contactId,
            lastMessage: msg,
            incrementUnread: !isMe,
          );
        }
      }
    } catch (e) {
      print("Error fetching new messages in ChatListNotifier: $e");
    }
  }

  void addOrUpdateContact({
    required String contactId,
    required Message lastMessage,
    bool incrementUnread = false,
  }) {
    final newMap = Map<String, Message>.from(state);
    final existingMessage = newMap[contactId];
    final currentUnread = existingMessage?.unreadCount ?? 0;

    final newUnread = incrementUnread ? (currentUnread + 1) : currentUnread;

    newMap[contactId] = lastMessage.copyWith(unreadCount: newUnread);

    state = newMap;
    _saveChatMapToHive(state);
  }

  void markAsRead(String contactId) {
    if (!state.containsKey(contactId)) return;

    final newMap = Map<String, Message>.from(state);
    final currentMsg = newMap[contactId];

    if (currentMsg != null) {
      newMap[contactId] = currentMsg.copyWith(unreadCount: 0);
      state = newMap;
      _saveChatMapToHive(state);
    }
  }

  Future<void> fetchLastMessages(List<String> contactIds) async {
    if (contactIds.isEmpty || _currentUserId == null || _isFetching) return;

    _isFetching = true;

    try {
      final futures = contactIds.map((contactId) async {
        try {
          final response = await _apiService.dio.get(
            "/api/v1/messages/$contactId/?limit=1&page=1",
          );
          if (response.statusCode == 200 && response.data['success'] == true) {
            final List<dynamic> messagesList =
                response.data['data']['messages'] ?? [];
            if (messagesList.isNotEmpty) {
              final json = messagesList.first;
              final String senderId = (json['senderId'] ?? '').toString();
              final String receiverId = (json['receiverId'] ?? '').toString();

              return MapEntry(
                contactId,
                Message(
                  id: (json['_id'] ?? '').toString(),
                  text: json['message'] ?? "",
                  senderId: senderId,
                  receiverId: receiverId,
                  isMe: senderId == _currentUserId,
                  timestamp: json['createdAt'] != null
                      ? DateTime.parse(json['createdAt'])
                      : DateTime.now(),
                  isSent: true,
                  isDelivered: json['delivered'] ?? false,
                  isRead: json['read'] ?? false,
                ),
              );
            }
          }
        } catch (e) {
          print("Error fetching for $contactId: $e");
        }
        return null;
      }).toList();

      final results = await Future.wait(futures);

      bool hasNewData = false;
      final newMap = Map<String, Message>.from(state);

      for (final entry in results) {
        if (entry != null) {
          hasNewData = true;
          final existingMsg = newMap[entry.key];
          final currentUnread = existingMsg?.unreadCount ?? 0;

          newMap[entry.key] = entry.value.copyWith(unreadCount: currentUnread);
        }
      }

      if (hasNewData) {
        state = newMap;
        _saveChatMapToHive(state);
      }
    } finally {
      _isFetching = false;
    }
  }
}

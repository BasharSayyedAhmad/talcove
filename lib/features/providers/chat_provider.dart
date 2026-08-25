import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/features/providers/chat_list_provider.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
import 'package:talcove/features/providers/notifire_provider.dart';
import 'package:talcove/models/message.dart';
import 'package:talcove/models/user.dart';
import 'package:talcove/shared/services/socket_service.dart';

part 'chat_provider.g.dart';

@riverpod
class MessageNotifier extends _$MessageNotifier {
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService();

  String? _currentUserId;
  String? _activeChatUserId;
  bool _isLoading = false;

  void Function(dynamic)? _onNewMessageHandler;
  void Function(dynamic)? _onMessageSentHandler;

  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;

  @override
  List<Message> build() {
    final authState = ref.watch(authNotifierProvider);
    _currentUserId = authState.user?.id;

    ref.onDispose(() {
      _tearDownListeners();
    });

    return [];
  }

  void clear() {
    _activeChatUserId = null;
    state = [];
  }

  String _extractId(dynamic rawData) {
    if (rawData == null) return '';
    if (rawData is Map) {
      return (rawData['id'] ?? rawData['_id'] ?? '').toString();
    }
    return rawData.toString();
  }

  String? _extractDeviceToken(dynamic rawData) {
    if (rawData == null) return null;
    if (rawData is Map<String, dynamic>) {
      return rawData['deviceToken']?.toString();
    }
    return null;
  }

  void setActiveChatUser(String? userId) {
    _activeChatUserId = userId;
  }

  void setupSocketListeners() {
    _tearDownListeners();

    _onNewMessageHandler = (dynamic data) {
      if (data == null || _currentUserId == null) return;

      final mapData = data as Map<String, dynamic>;
      final newMessage = Message.fromSocket(mapData, _currentUserId!);

      final senderId = _extractId(mapData['sender']).isNotEmpty
          ? _extractId(mapData['sender'])
          : newMessage.senderId;

      final receiverId = _extractId(mapData['receiver']).isNotEmpty
          ? _extractId(mapData['receiver'])
          : newMessage.receiverId;

      final senderToken = _extractDeviceToken(mapData['sender']);

      String extractedUserName = senderId;
      if (mapData['sender'] is Map) {
        final senderMap = mapData['sender'] as Map<String, dynamic>;
        extractedUserName =
            senderMap['senderUserName'] ?? senderMap['userName'] ?? senderId;
      } else if (mapData['senderUserName'] != null) {
        extractedUserName = mapData['senderUserName'].toString();
      }

      // 1. إضافة المُرْسِل لقائمة الجهات وتحديث التوكن الخاص به
      final contacts = ref.read(contactsNotifierProvider);
      if (!contacts.any((c) => c.id == senderId)) {
        ref
            .read(contactsNotifierProvider.notifier)
            .addContact(
              User(
                id: senderId,
                userName: extractedUserName,
                deviceToken: senderToken,
              ),
            );
      }

      final isMessageForActiveChat =
          _activeChatUserId != null &&
          (_activeChatUserId == senderId || _activeChatUserId == receiverId);

      // 2. إضافة/تحديث المحادثة في chatList عند استلام رسالة جديدة
      ref
          .read(chatListNotifierProvider.notifier)
          .addOrUpdateContact(
            contactId: senderId,
            lastMessage: newMessage,
            incrementUnread: !isMessageForActiveChat,
          );

      if (!isMessageForActiveChat) return;

      final existingIndex = state.indexWhere((m) => m.id == newMessage.id);
      if (existingIndex != -1) {
        final updated = List<Message>.from(state);
        updated[existingIndex] = newMessage;
        state = updated;
      } else {
        state = [...state, newMessage];
      }
    };

    _onMessageSentHandler = (dynamic data) {
      if (data == null || _currentUserId == null) return;

      final mapData = data as Map<String, dynamic>;
      final sentMessage = Message.fromSocket(mapData, _currentUserId!);

      final receiverId = _extractId(mapData['receiver']).isNotEmpty
          ? _extractId(mapData['receiver'])
          : sentMessage.receiverId;

      // تحديث قائمة المحادثات عند إرسال رسالة
      ref
          .read(chatListNotifierProvider.notifier)
          .addOrUpdateContact(contactId: receiverId, lastMessage: sentMessage);

      final isMessageForActiveChat =
          _activeChatUserId != null &&
          (_activeChatUserId == receiverId ||
              _activeChatUserId == sentMessage.senderId);

      if (!isMessageForActiveChat) return;

      final List<Message> current = List<Message>.from(state);

      final realIdAlreadyExists = current.any(
        (m) => m.id == sentMessage.id && !m.id.startsWith('temp_'),
      );

      final tempIndex = current.indexWhere(
        (m) =>
            m.id.startsWith('temp_') &&
            m.text.trim() == sentMessage.text.trim() &&
            (m.receiverId == receiverId ||
                m.receiverId == sentMessage.receiverId),
      );

      if (tempIndex != -1) {
        if (realIdAlreadyExists) {
          current.removeAt(tempIndex);
        } else {
          current[tempIndex] = sentMessage;
        }
        state = current;
      } else if (!realIdAlreadyExists) {
        state = [...current, sentMessage];
      }
    };

    _socketService.onNewMessage(_onNewMessageHandler!);
    _socketService.onMessageSent(_onMessageSentHandler!);
  }

  void _tearDownListeners() {
    if (_onNewMessageHandler != null) {
      _socketService.offNewMessage(_onNewMessageHandler!);
      _onNewMessageHandler = null;
    }
    if (_onMessageSentHandler != null) {
      _socketService.offMessageSent(_onMessageSentHandler!);
      _onMessageSentHandler = null;
    }
  }

  void detachListeners() {
    _tearDownListeners();
  }

  void sendMessageToSocket(
    String text,
    String receiverId, {
    String? receiverFcmToken,
  }) async {
    if (text.trim().isEmpty) return;

    final contacts = ref.read(contactsNotifierProvider);
    final targetContact = contacts.where((c) => c.id == receiverId).firstOrNull;

    final finalToken = receiverFcmToken ?? targetContact?.deviceToken;

    final tempId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
    final tempMessage = Message(
      id: tempId,
      text: text.trim(),
      senderId: _currentUserId ?? '',
      receiverId: receiverId,
      timestamp: DateTime.now(),
      isMe: true,
      isSent: false,
      isDelivered: false,
      isRead: false,
    );

    state = [...state, tempMessage];

    ref
        .read(chatListNotifierProvider.notifier)
        .addOrUpdateContact(contactId: receiverId, lastMessage: tempMessage);
    _socketService.sendMessage(text.trim(), receiverId);
    if (finalToken != null && finalToken.isNotEmpty) {
      final currentUser = ref.read(authNotifierProvider).user;
      final senderName = currentUser?.userName ?? 'رسالة جديدة';

      sendNotificationToUser(
        receiverFcmToken: finalToken,
        title: senderName,
        body: text.trim(),
        chatRoomId: _currentUserId,
        data: {
          'senderId': _currentUserId ?? '',
          'senderName': senderName,
          'profileImage': currentUser?.photoUrl ?? '',
        },
      );
    } else {
      print(' لم يتم العثور على FCM Token للمستقبل: $receiverId');
    }
  }

  void connectSocket(String userId, String token) {
    _currentUserId = userId;
    _socketService.connect(token, userId);
  }

  void disconnectSocket() {
    _tearDownListeners();
    _socketService.disconnect();
  }

  void editMessage(int index, String newText) {
    if (index < 0 || index >= state.length) return;
    final updated = List<Message>.from(state);
    updated[index] = updated[index].copyWith(text: newText, isEdited: true);
    state = updated;
  }

  void deleteMessage(int index) {
    if (index < 0 || index >= state.length) return;
    final updated = List<Message>.from(state)..removeAt(index);
    state = updated;
  }

  void clearMessages() => state = [];

  Future<void> fetchMessagesWithUser({
    required String otherUserId,
    int limit = 10,
    int page = 1,
  }) async {
    try {
      _isLoading = true;
      _activeChatUserId = otherUserId;

      final response = await _apiService.dio.get(
        '/api/v1/messages/$otherUserId/?limit=$limit&page=$page',
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = response.data['data']['messages'];
        final messages = messagesData.map((json) {
          final sId = _extractId(json['senderId'] ?? json['sender']);
          final rId = _extractId(json['receiverId'] ?? json['receiver']);

          return Message(
            id: (json['_id'] ?? json['id']).toString(),
            text: json['message'] ?? json['text'] ?? '',
            senderId: sId,
            receiverId: rId,
            isMe: sId == _currentUserId,
            timestamp: DateTime.parse(json['createdAt']),
            isSent: true,
            isDelivered: json['delivered'] ?? false,
            isRead: json['read'] ?? false,
          );
        }).toList();

        final sorted = messages.reversed.toList();
        state = page == 1 ? sorted : [...sorted, ...state];
      }
    } catch (e) {
      print(' Error loading messages: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> fetchNewMessages() async {
    try {
      final response = await _apiService.dio.get('/api/v1/messages/new');
      if (response.statusCode == 200) {
        final List<dynamic> messagesData = response.data['data']['newMessages'];
        final newMessages = messagesData.map((json) {
          final sId = _extractId(json['senderId'] ?? json['sender']);
          final rId = _extractId(json['receiverId'] ?? json['receiver']);

          return Message(
            id: json['id'].toString(),
            text: json['text'] ?? json['message'] ?? '',
            senderId: sId,
            receiverId: rId,
            isMe: sId == _currentUserId,
            timestamp: DateTime.parse(json['createdAt']),
            isSent: true,
            isDelivered: json['delivered'] ?? false,
            isRead: json['read'] ?? false,
          );
        }).toList();

        final existingIds = state.map((m) => m.id).toSet();
        final unique = newMessages
            .where((m) => !existingIds.contains(m.id))
            .toList();

        if (unique.isNotEmpty) state = [...state, ...unique];
      }
    } catch (e) {
      print('❌ Error fetching new messages: $e');
    }
  }

  Future<void> fetchLastMessageForContacts(List<String> contactIds) async {
    if (contactIds.isEmpty || _currentUserId == null) return;
    try {
      final futures = contactIds.map((contactId) async {
        try {
          final response = await _apiService.dio.get(
            '/api/v1/messages/$contactId/?limit=1&page=1',
          );
          if (response.statusCode == 200) {
            final List<dynamic> data = response.data['data']['messages'];
            if (data.isNotEmpty) {
              final json = data.first;
              final sId = _extractId(json['senderId'] ?? json['sender']);
              final rId = _extractId(json['receiverId'] ?? json['receiver']);

              return Message(
                id: (json['_id'] ?? json['id']).toString(),
                text: json['message'] ?? json['text'] ?? '',
                senderId: sId,
                receiverId: rId,
                isMe: sId == _currentUserId,
                timestamp: DateTime.parse(json['createdAt']),
                isSent: true,
                isDelivered: json['delivered'] ?? false,
                isRead: json['read'] ?? false,
              );
            }
          }
        } catch (_) {}
        return null;
      });

      final results = await Future.wait(futures);
      for (final msg in results.whereType<Message>()) {
        final targetId = msg.isMe ? msg.receiverId : msg.senderId;
        ref
            .read(chatListNotifierProvider.notifier)
            .addOrUpdateContact(contactId: targetId, lastMessage: msg);
      }
    } catch (e) {
      print('❌ Error fetching last messages: $e');
    }
  }
}

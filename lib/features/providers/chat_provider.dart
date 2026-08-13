import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/features/providers/chat_list_provider.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
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

  late void Function(dynamic) _onNewMessageHandler;
  late void Function(dynamic) _onMessageSentHandler;
  bool _listenersActive = false;

  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;

  @override
  List<Message> build() {
    final authState = ref.read(authNotifierProvider);
    _currentUserId = authState.user?.id;

    ref.onDispose(() {
      _tearDownListeners();
    });

    return [];
  }

  void setActiveChatUser(String? userId) {
    _activeChatUserId = userId;
  }

  void setupSocketListeners() {
    if (_listenersActive) {
      _tearDownListeners();
    }

    _onNewMessageHandler = (dynamic data) {
      if (data == null || _currentUserId == null) return;

      final newMessage = Message.fromSocket(
        data as Map<String, dynamic>,
        _currentUserId!,
      );

      // 1. إضافة جهة الاتصال دائماً في الخلفية
      final contacts = ref.read(contactsNotifierProvider);
      if (!contacts.any((c) => c.id == newMessage.senderId)) {
        ref
            .read(contactsNotifierProvider.notifier)
            .addContact(
              User(
                id: newMessage.senderId,
                userName: (data)['senderUserName'] ?? newMessage.senderId,
              ),
            );
      }

      // 2. تحديث قائمة المحادثات العامة (Chat List) دائماً
      ref
          .read(chatListNotifierProvider.notifier)
          .addOrUpdateContact(
            contactId: newMessage.senderId,
            lastMessage: newMessage,
          );

      // 3. 🎯 الإصلاح الجذري: تحقّق هل الرسالة تخص المحادثة المفتوحة حالياً أمام المستخدم؟
      final isMessageForActiveChat =
          _activeChatUserId != null &&
          (newMessage.senderId == _activeChatUserId ||
              newMessage.receiverId == _activeChatUserId);

      // إذا لم تكن للمحادثة النشطة، لا تحقنها في state الشاشة المفتوحة!
      if (!isMessageForActiveChat) return;

      // تحديث شاشة الشات الحالية إن كانت مطابقة
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

      final sentMessage = Message.fromSocket(
        data as Map<String, dynamic>,
        _currentUserId!,
      );

      // تحديث قائمة المحادثات العامة دائماً
      ref
          .read(chatListNotifierProvider.notifier)
          .addOrUpdateContact(
            contactId: sentMessage.receiverId,
            lastMessage: sentMessage,
          );

      // 🎯 تحقق هل تأكيد الإرسال يعود للمحادثة النشطة حالياً؟
      final isMessageForActiveChat =
          _activeChatUserId != null &&
          (sentMessage.receiverId == _activeChatUserId ||
              sentMessage.senderId == _activeChatUserId);

      if (!isMessageForActiveChat) return;

      final List<Message> current = List<Message>.from(state);

      final realIdAlreadyExists = current.any(
        (m) => m.id == sentMessage.id && !m.id.startsWith('temp_'),
      );

      final tempIndex = current.indexWhere(
        (m) =>
            m.id.startsWith('temp_') &&
            m.text.trim() == sentMessage.text.trim() &&
            m.receiverId == sentMessage.receiverId,
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

    _socketService.onNewMessage(_onNewMessageHandler);
    _socketService.onMessageSent(_onMessageSentHandler);
    _listenersActive = true;
  }

  void _tearDownListeners() {
    if (!_listenersActive) return;
    _socketService.offNewMessage(_onNewMessageHandler);
    _socketService.offMessageSent(_onMessageSentHandler);
    _listenersActive = false;
  }

  void detachListeners() {
    _activeChatUserId = null;
    _tearDownListeners();
  }

  void sendMessageToSocket(String text, String receiverId) {
    if (text.trim().isEmpty) return;

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
      _activeChatUserId = otherUserId; // 👈 ضبط المستلم النشط عند جلب المحادثة

      final response = await _apiService.dio.get(
        '/api/v1/messages/$otherUserId/?limit=$limit&page=$page',
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = response.data['data']['messages'];
        final messages = messagesData.map((json) {
          return Message(
            id: json['_id'],
            text: json['message'] ?? '',
            senderId: json['senderId'],
            receiverId: json['receiverId'],
            isMe: json['senderId'] == _currentUserId,
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
      print('❌ Error loading messages: $e');
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
          return Message(
            id: json['id'].toString(),
            text: json['text'] ?? '',
            senderId: json['senderId'] ?? '',
            receiverId: json['receiverId'] ?? '',
            isMe: json['senderId'] == _currentUserId,
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
              return Message(
                id: json['_id'],
                text: json['message'] ?? '',
                senderId: json['senderId'],
                receiverId: json['receiverId'],
                isMe: json['senderId'] == _currentUserId,
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

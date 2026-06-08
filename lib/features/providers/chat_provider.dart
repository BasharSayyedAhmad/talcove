import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/features/providers/auth_provider.dart';
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
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  @override
  List<Message> build() {
    final authState = ref.watch(authNotifierProvider);
    _currentUserId = authState.user?.id;

    _setupSocketListeners();
    return [];
  }

  void _setupSocketListeners() {
    _socketService.onNewMessage((data) {
      if (_currentUserId == null) return;

      if (data['senderId'] == _currentUserId) return;
      if (data['receiverId'] != _currentUserId) return;
      final contacts = ref.read(contactsNotifierProvider);
      final senderExists = contacts.any((c) => c.id == data['senderId']);

      if (!senderExists) {
        // أضف المستخدم الجديد إلى الـ contacts تلقائياً
        final newUser = User(
          id: data['senderId'],
          userName: data['senderUserName'] ?? data['senderId'],
        );
        ref.read(contactsNotifierProvider.notifier).addContact(newUser);
        print(" Added new contact from message: ${newUser.userName}");
      }

      final newMessage = Message(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: data['message'],
        senderId: data['senderId'],
        receiverId: data['receiverId'] ?? _currentUserId ?? '',
        isMe: false,
        timestamp: DateTime.parse(data['createdAt']),
        isSent: true,
        isDelivered: data['delivered'] ?? false,
      );

      //  دايماً نضيف للـ state — حتى لو ChatScreen مش مفتوحة
      // orderedContactsNotifierProvider يراقب هاد ويتحدث فوراً
      state = [...state, newMessage];
    });
  }

  void connectSocket(String userId, String token) {
    _currentUserId = userId;
    _socketService.connect(token, userId);
  }

  void disconnectSocket() {
    _socketService.disconnect();
  }

  /// فقط يرسل عبر الـ socket — لا يضيف للـ state
  /// (الإضافة تصير في الـ UI مباشرة عبر _messages المحلية في ChatScreen)
  void sendMessageToSocket(String text, String receiverId) {
    if (text.trim().isEmpty) return;
    _socketService.sendMessage(text, receiverId);
  }

  void editMessage(int index, String newText) {
    if (index >= 0 && index < state.length) {
      final updated = List<Message>.from(state);
      updated[index] = updated[index].copyWith(text: newText, isEdited: true);
      state = updated;
    }
  }

  void deleteMessage(int index) {
    if (index >= 0 && index < state.length) {
      final updated = List<Message>.from(state);
      updated.removeAt(index);
      state = updated;
    }
  }

  Future<void> fetchMessagesWithUser({
    required String otherUserId,
    int limit = 10,
    int page = 1,
  }) async {
    try {
      print(" _currentUserId: $_currentUserId");
      print(" otherUserId: $otherUserId");
      _isLoading = true;

      final response = await _apiService.dio.get(
        "/api/v1/messages/$otherUserId/?limit=$limit&page=$page",
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = response.data['data']['messages'];
        print(" Found ${messagesData.length} messages");

        final List<Message> messages = messagesData.map((json) {
          return Message(
            id: json['_id'],
            text: json['message'] ?? "",
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

        if (page == 1) {
          state = sorted;
        } else {
          state = [...sorted, ...state];
        }
      }
    } catch (e) {
      print(" Error loading messages: $e");
    } finally {
      _isLoading = false;
    }
  }

  Future<void> fetchNewMessages() async {
    try {
      final response = await _apiService.dio.get('/api/v1/messages/new');

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = response.data['data']['newMessages'];
        final List<Message> newMessages = messagesData.map((json) {
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
        final uniqueMessages = newMessages
            .where((m) => !existingIds.contains(m.id))
            .toList();

        if (uniqueMessages.isNotEmpty) {
          state = [...state, ...uniqueMessages];
        }
      }
    } catch (e) {
      print("❌ Error fetching new messages: $e");
    }
  }

  /// يُستدعى مرة وحدة عند فتح ChatListScreen
  Future<void> fetchLastMessageForContacts(List<String> contactIds) async {
    if (contactIds.isEmpty || _currentUserId == null) return;

    try {
      final futures = contactIds.map((contactId) async {
        try {
          final response = await _apiService.dio.get(
            "/api/v1/messages/$contactId/?limit=1&page=1",
          );
          print("trying to fetch last messages....");
          print("repsonse data:${response.data}");
          if (response.statusCode == 200) {
            final List<dynamic> data = response.data['data']['messages'];
            if (data.isNotEmpty) {
              final json = data.first;
              return Message(
                id: json['_id'],
                text: json['message'] ?? "",
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
      }).toList();

      final results = await Future.wait(futures);

      final newMessages = results.whereType<Message>().toList();
      if (newMessages.isEmpty) return;

      // أضف بس الرسائل اللي مش موجودة أصلاً في الـ state
      final existingIds = state.map((m) => m.id).toSet();
      final unique = newMessages
          .where((m) => !existingIds.contains(m.id))
          .toList();

      if (unique.isNotEmpty) {
        state = [...state, ...unique];
      }
    } catch (e) {
      print(" Error fetching last messages: $e");
    }
  }

  void clearMessages() {
    state = [];
  }

  String? get currentUserId => _currentUserId;
}

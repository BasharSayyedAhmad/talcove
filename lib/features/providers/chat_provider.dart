import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/models/message.dart';
import 'package:talcove/shared/services/socket_service.dart';
part 'chat_provider.g.dart';

@riverpod
class MessageNotifier extends _$MessageNotifier {
  late final SocketService _socketService;
  String? _currentUserId;

  @override
  List<Message> build() {
    _socketService = SocketService();
    _setupSocketListeners();
    return [];
  }

  void _setupSocketListeners() {
    _socketService.onNewMessage((data) {
      if (_currentUserId == null) return;
      final newMessage = Message(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: data['message'],
        senderId: data['senderUserName'].toString(),
        receiverId: data['receiverUserName'].toString(),
        isMe: data['senderUserName'] == _currentUserId,
        timestamp: DateTime.parse(data['createdAt']),
        isSent: true,
        isDelivered: true,
      );

      state = [...state, newMessage];
    });
  }

  void connectSocket(String userName, String token) {
    _currentUserId = userName;
    _socketService.connect(token);
  }

  void disconnectSocket() {
    _socketService.disconnect();
  }

  ///  فقط يرسل عبر الـ socket — لا يضيف للـ state
  /// (الإضافة تصير في الـ UI مباشرة عبر _messages المحلية)
  void sendMessageToSocket(String text, String receiverUserName) {
    if (text.trim().isEmpty) return;
    _socketService.sendMessage(text, receiverUserName);
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

  void clearMessages() {
    state = [];
  }

  String? get currentUserId => _currentUserId;
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/features/providers/auth_provider.dart'; // استيراد الـ Auth لربط المستخدم
import 'package:talcove/features/providers/chat_provider.dart';
import 'package:talcove/models/message.dart';

part 'chat_list_provider.g.dart';

@riverpod
class ChatListNotifier extends _$ChatListNotifier {
  final ApiService _apiService = ApiService();
  String? _currentUserId;
  bool _isFetching = false;

  @override
  Map<String, Message> build() {
    // 1. تحديث الـ currentUserId تلقائياً بناءً على حالة تسجيل الدخول
    final authState = ref.watch(authNotifierProvider);
    _currentUserId = authState.user?.id;

    // 2. مراقبة الـ MessageNotifier لمعالجة الرسائل الجديدة الحية والغيابية
    ref.listen(messageNotifierProvider, (previous, next) {
      if (next.isNotEmpty) {
        // نأخذ الرسائل الجديدة فقط التي أضيفت في هذا التحديث
        final previousLength = previous?.length ?? 0;
        if (next.length > previousLength) {
          final newMessages = next.sublist(previousLength);

          // نقوم بإنشاء نسخة مؤقتة من الـ state لتحديثها دفعة واحدة وكفاءة عالية
          final updatedMap = Map<String, Message>.from(state);

          for (final msg in newMessages) {
            if (_currentUserId == null) continue;

            // تحديد الطرف الآخر في المحادثة
            final contactId = msg.senderId == _currentUserId
                ? msg.receiverId
                : msg.senderId;

            // نتحقق: إذا لم تكن هناك رسالة مسجلة لهذا الشخص، أو كانت الرسالة الجديدة أحدث زمنياً
            final currentLastMsg = updatedMap[contactId];
            if (currentLastMsg == null ||
                msg.timestamp.isAfter(currentLastMsg.timestamp)) {
              updatedMap[contactId] = msg;
            }
          }

          // تحديث الـ State بالخريطة الجديدة كاملة ليحدث الـ UI مرة واحدة
          state = updatedMap;
        }
      }
    });

    return {};
  }

  bool get isFetching => _isFetching;

  Future<void> fetchLastMessages(List<String> contactIds) async {
    if (contactIds.isEmpty || _currentUserId == null) return;
    if (_isFetching) return;

    _isFetching = true;

    try {
      final futures = contactIds.map((contactId) async {
        try {
          final response = await _apiService.dio.get(
            "/api/v1/messages/$contactId/?limit=1&page=1",
          );
          if (response.statusCode == 200) {
            final List<dynamic> data = response.data['data']['messages'];
            if (data.isNotEmpty) {
              final json = data.first;
              return MapEntry(
                contactId,
                Message(
                  id: json['_id'],
                  text: json['message'] ?? "",
                  senderId: json['senderId'],
                  receiverId: json['receiverId'],
                  isMe: json['senderId'] == _currentUserId,
                  timestamp: DateTime.parse(json['createdAt']),
                  isSent: true,
                  isDelivered: json['delivered'] ?? false,
                  isRead: json['read'] ?? false,
                ),
              );
            }
          }
        } catch (e) {
          print(" ❌ Error fetching for $contactId: $e");
        }
        return null;
      }).toList();

      final results = await Future.wait(futures);

      final newMap = Map<String, Message>.from(state);
      for (final entry in results) {
        if (entry != null) {
          newMap[entry.key] = entry.value;
        }
      }
      state = newMap;
    } finally {
      _isFetching = false;
    }
  }

  void addOrUpdateContact({
    required String contactId,
    required Message lastMessage,
  }) {
    final newMap = Map<String, Message>.from(state);

    // إذا ما في رسالة سابقة لهذا الشخص → أضفو
    if (!newMap.containsKey(contactId)) {
      newMap[contactId] = lastMessage;
      state = newMap;
      return;
    }

    // إذا في رسالة سابقة → حدّث فقط إذا الرسالة الجديدة أحدث
    final oldMessage = newMap[contactId]!;
    if (lastMessage.timestamp.isAfter(oldMessage.timestamp)) {
      newMap[contactId] = lastMessage;
      state = newMap;
    }
  }

  void updateLastMessage({
    required String contactId,
    required Message message,
  }) {
    final newMap = Map<String, Message>.from(state);
    newMap[contactId] = message;
    state = newMap;
  }
}

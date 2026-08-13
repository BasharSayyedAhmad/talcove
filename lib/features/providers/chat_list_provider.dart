import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
import 'package:talcove/models/message.dart';
import 'package:talcove/models/user.dart';
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
          final mapData = data as Map<String, dynamic>;
          print("📥 Processing socket message in ChatListNotifier...");

          final newMessage = Message(
            id:
                mapData['_id'] ??
                mapData['createdAt'] ??
                DateTime.now().toString(),
            text: mapData['message'] ?? "",
            senderId: mapData['senderId'] ?? "",
            receiverId: mapData['receiverId'] ?? "",
            isMe: mapData['senderId'] == _currentUserId,
            timestamp: mapData['createdAt'] != null
                ? DateTime.parse(mapData['createdAt'])
                : DateTime.now(),
            isSent: true,
            isDelivered: mapData['delivered'] ?? true,
            isRead: mapData['read'] ?? false,
          );

          final contactId = newMessage.senderId == _currentUserId
              ? newMessage.receiverId
              : newMessage.senderId;

          print("🎯 Adding message to contact: $contactId");

          // 🔥 التعديل: التأكد من حفظ المستخدم في Hive عبر ContactsNotifier
          final contactsNotifier = ref.read(contactsNotifierProvider.notifier);
          final existingContact = contactsNotifier.getContactById(contactId);

          if (existingContact == null) {
            print(
              "🕵️ New sender detected! Saving to Hive via ContactsNotifier...",
            );

            // إنشاء مستخدم مؤقت بالاعتماد على الـ ID
            final newUser = User(
              id: contactId,
              userName: "User_${contactId.substring(contactId.length - 4)}",
              photoUrl: null,
              email: '',
            );

            // هذه الدالة ستقوم بتحديث الـ state وحفظ البيانات في Hive تلقائياً
            contactsNotifier.addContact(newUser);
          }

          // ✅ تحديث قائمة المحادثات (الرسالة الأخيرة)
          addOrUpdateContact(contactId: contactId, lastMessage: newMessage);
        } catch (e, stack) {
          print("❌ Error parsing socket message in ChatListNotifier: $e");
          print(stack);
        }
      });
    }

    ref.onDispose(() {
      _isSocketListening = false;
    });

    // ✅ المرجع الصحيح لريفربود: إرجاع Map فارغة كحالة ابتدائية آمنة عند أول بناء
    return {};
  }

  bool get isFetching => _isFetching;

  // دالة الـ fetchLastMessages بتضل متل ما هيي وبتستخدم state عادي
  Future<void> fetchLastMessages(List<String> contactIds) async {
    if (contactIds.isEmpty || _currentUserId == null || _isFetching) return;

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

      // ✅ هون بنقرا الـ state بأمان لأننا برات الـ build
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
    // 🔥 إنشاء مرجع جديد كلياً في الذاكرة لتنبيه Riverpod
    final newMap = Map<String, Message>.from(state);

    if (!newMap.containsKey(contactId)) {
      newMap[contactId] = lastMessage;
      state = newMap; // 🚀 إسناد المرجع الجديد للـ state
      print("✅ State updated inside ChatListNotifier (New Contact Added)");
      return;
    }

    final oldMessage = newMap[contactId]!;
    if (lastMessage.timestamp.isAfter(oldMessage.timestamp)) {
      newMap[contactId] = lastMessage;
      state = newMap; // 🚀 إسناد المرجع الجديد للـ state
      print(
        "✅ State updated inside ChatListNotifier (Existing Contact Updated)",
      );
    }
  }
}

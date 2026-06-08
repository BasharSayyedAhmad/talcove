// import 'package:flutter/material.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:talcove/core/services/api_service.dart';
// import 'package:talcove/features/providers/auth_provider.dart';
// import 'package:talcove/features/providers/contacts_provider.dart';
// import 'package:talcove/models/message.dart';
// import 'package:talcove/models/user.dart';
// import 'package:talcove/shared/services/socket_service.dart';
// part 'chat_provider.g.dart';

// @riverpod
// class MessageNotifier extends _$MessageNotifier {
//   final SocketService _socketService = SocketService();
//   final ApiService _apiService = ApiService();
//   String? _currentUserId;
//   bool _isLoading = false;

//   bool get isLoading => _isLoading;
//   // bool _listenersSetup = false;
//   // احذف _listenersSetup بالكامل

//   @override
//   List<Message> build() {
//     final authState = ref.watch(authNotifierProvider);
//     _currentUserId = authState.user?.id;

//     if (_currentUserId != null) {
//       // ← أوقف الـ listener القديم أول قبل ما تسجل جديد

//       _setupSocketListeners();

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         fetchNewMessages();
//       });

//       // ← لما الـ provider ينتهي، أوقف الـ listener
//       ref.onDispose(() {
//         _socketService.offNewMessage();
//       });
//     }

//     return [];
//   }
//   // @override
//   // List<Message> build() {
//   //   final authState = ref.watch(authNotifierProvider);
//   //   _currentUserId = authState.user?.id;

//   //   if (_currentUserId != null) {
//   //     _setupSocketListeners();

//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       fetchNewMessages();
//   //     });
//   //   }

//   //   return [];
//   // }

//   void _setupSocketListeners() {
//     _socketService.onNewMessage((data) {
//       if (_currentUserId == null) return;

//       // إذا كنت أنا المرسل، السيرفر سيعيد بثها ليتأكد التسليم، يمكننا فلترتها هنا أو تحديث حالتها
//       // لكن لمنع التكرار سنعتمد على الفحص الذكي

//       final contacts = ref.read(contactsNotifierProvider);
//       final senderExists = contacts.any((c) => c.id == data['senderId']);

//       if (!senderExists) {
//         final newUser = User(
//           id: data['senderId'],
//           userName: data['senderUserName'] ?? data['senderId'],
//         );
//         ref.read(contactsNotifierProvider.notifier).addContact(newUser);
//       }

//       final newMessage = Message(
//         // تأكد أن الباك إيند يرسل id أو _id في الـ data، إذا لم يرسله استخدم وقتاً موحداً
//         id:
//             data['_id'] ??
//             data['id'] ??
//             DateTime.now().microsecondsSinceEpoch.toString(),
//         text: data['message'],
//         senderId: data['senderId'],
//         receiverId: data['receiverId'] ?? _currentUserId ?? '',
//         isMe:
//             data['senderId'] ==
//             _currentUserId, // اجعلها ديناميكية بناءً على المرسل
//         timestamp: data['createdAt'] != null
//             ? DateTime.parse(data['createdAt'])
//             : DateTime.now(),
//         isSent: true,
//         isDelivered: data['delivered'] ?? false,
//       );

//       // منع الإضافة إذا كانت الرسالة موجودة مسبقاً بالـ ID في الـ Provider state
//       final alreadyExists = state.any((msg) => msg.id == newMessage.id);
//       if (!alreadyExists) {
//         state = [...state, newMessage];
//       }
//     });
//   }

//   void connectSocket(String userId, String token) {
//     _currentUserId = userId;
//     _socketService.connect(token, userId);
//   }

//   void disconnectSocket() {
//     _socketService.disconnect();
//   }

//   /// فقط يرسل عبر الـ socket — لا يضيف للـ state
//   /// (الإضافة تصير في الـ UI مباشرة عبر _messages المحلية في ChatScreen)
//   void sendMessageToSocket(String text, String receiverId) {
//     if (text.trim().isEmpty) return;
//     _socketService.sendMessage(text, receiverId);
//   }

//   void editMessage(int index, String newText) {
//     if (index >= 0 && index < state.length) {
//       final updated = List<Message>.from(state);
//       updated[index] = updated[index].copyWith(text: newText, isEdited: true);
//       state = updated;
//     }
//   }

//   void deleteMessage(int index) {
//     if (index >= 0 && index < state.length) {
//       final updated = List<Message>.from(state);
//       updated.removeAt(index);
//       state = updated;
//     }
//   }

//   Future<void> fetchMessagesWithUser({
//     required String otherUserId,
//     int limit = 10,
//     int page = 1,
//   }) async {
//     try {
//       print(" _currentUserId: $_currentUserId");
//       print(" otherUserId: $otherUserId");
//       _isLoading = true;

//       final response = await _apiService.dio.get(
//         "/api/v1/messages/$otherUserId/?limit=$limit&page=$page",
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> messagesData = response.data['data']['messages'];
//         print(" Found ${messagesData.length} messages");

//         final List<Message> messages = messagesData.map((json) {
//           return Message(
//             id: json['_id'],
//             text: json['message'] ?? "",
//             senderId: json['senderId'],
//             receiverId: json['receiverId'],
//             isMe: json['senderId'] == _currentUserId,
//             timestamp: DateTime.parse(json['createdAt']),
//             isSent: true,
//             isDelivered: json['delivered'] ?? false,
//             isRead: json['read'] ?? false,
//           );
//         }).toList();

//         final sorted = messages.reversed.toList();

//         if (page == 1) {
//           state = sorted;
//         } else {
//           state = [...sorted, ...state];
//         }
//       }
//     } catch (e) {
//       print(" Error loading messages: $e");
//     } finally {
//       _isLoading = false;
//     }
//   }

//   Future<void> fetchNewMessages() async {
//     try {
//       final response = await _apiService.dio.get('/api/v1/messages/new');

//       if (response.statusCode == 200) {
//         final List<dynamic> messagesData = response.data['data']['newMessages'];
//         final List<Message> newMessages = messagesData.map((json) {
//           return Message(
//             id: json['id'].toString(),
//             text: json['text'] ?? '',
//             senderId: json['senderId'] ?? '',
//             receiverId: json['receiverId'] ?? '',
//             isMe: json['senderId'] == _currentUserId,
//             timestamp: DateTime.parse(json['createdAt']),
//             isSent: true,
//             isDelivered: json['delivered'] ?? false,
//             isRead: json['read'] ?? false,
//           );
//         }).toList();

//         final existingIds = state.map((m) => m.id).toSet();
//         final uniqueMessages = newMessages
//             .where((m) => !existingIds.contains(m.id))
//             .toList();

//         if (uniqueMessages.isNotEmpty) {
//           state = [...state, ...uniqueMessages];
//         }
//       }
//     } catch (e) {
//       print("❌ Error fetching new messages: $e");
//     }
//   }

//   /// يُستدعى مرة وحدة عند فتح ChatListScreen
//   Future<void> fetchLastMessageForContacts(List<String> contactIds) async {
//     if (contactIds.isEmpty || _currentUserId == null) return;

//     try {
//       final futures = contactIds.map((contactId) async {
//         try {
//           final response = await _apiService.dio.get(
//             "/api/v1/messages/$contactId/?limit=1&page=1",
//           );
//           print("trying to fetch last messages....");
//           print("repsonse data:${response.data}");
//           if (response.statusCode == 200) {
//             final List<dynamic> data = response.data['data']['messages'];
//             if (data.isNotEmpty) {
//               final json = data.first;
//               return Message(
//                 id: json['_id'],
//                 text: json['message'] ?? "",
//                 senderId: json['senderId'],
//                 receiverId: json['receiverId'],
//                 isMe: json['senderId'] == _currentUserId,
//                 timestamp: DateTime.parse(json['createdAt']),
//                 isSent: true,
//                 isDelivered: json['delivered'] ?? false,
//                 isRead: json['read'] ?? false,
//               );
//             }
//           }
//         } catch (_) {}
//         return null;
//       }).toList();

//       final results = await Future.wait(futures);

//       final newMessages = results.whereType<Message>().toList();
//       if (newMessages.isEmpty) return;

//       // أضف بس الرسائل اللي مش موجودة أصلاً في الـ state
//       final existingIds = state.map((m) => m.id).toSet();
//       final unique = newMessages
//           .where((m) => !existingIds.contains(m.id))
//           .toList();

//       if (unique.isNotEmpty) {
//         state = [...state, ...unique];
//       }
//     } catch (e) {
//       print(" Error fetching last messages: $e");
//     }
//   }

//   void clearMessages() {
//     state = [];
//   }

//   String? get currentUserId => _currentUserId;
// }
// import 'package:flutter/material.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:talcove/core/services/api_service.dart';
// import 'package:talcove/features/providers/auth_provider.dart';
// import 'package:talcove/features/providers/contacts_provider.dart';
// import 'package:talcove/models/message.dart';
// import 'package:talcove/models/user.dart';
// import 'package:talcove/shared/services/socket_service.dart';
// part 'chat_provider.g.dart';

// @riverpod
// class MessageNotifier extends _$MessageNotifier {
//   final SocketService _socketService = SocketService();
//   final ApiService _apiService = ApiService();
//   String? _currentUserId;
//   bool _isLoading = false;

//   bool get isLoading => _isLoading;

//   @override
//   List<Message> build() {
//     final authState = ref.watch(authNotifierProvider);
//     _currentUserId = authState.user?.id;

//     if (_currentUserId != null) {
//       _setupSocketListeners();

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         fetchNewMessages();
//       });

//       ref.onDispose(() {
//         _socketService.offNewMessage();
//       });
//     }

//     return [];
//   }

//   void _setupSocketListeners() {
//     _socketService.offNewMessage();

//     _socketService.onNewMessage((data) {
//       if (_currentUserId == null) return;

//       final contacts = ref.read(contactsNotifierProvider);
//       final senderExists = contacts.any((c) => c.id == data['senderId']);

//       if (!senderExists) {
//         final newUser = User(
//           id: data['senderId'],
//           userName: data['senderUserName'] ?? data['senderId'],
//         );
//         ref.read(contactsNotifierProvider.notifier).addContact(newUser);
//       }

//       final serverId =
//           data['_id'] ??
//           data['id'] ??
//           DateTime.now().microsecondsSinceEpoch.toString();

//       final newMessage = Message(
//         id: serverId,
//         text: data['message'] ?? '',
//         senderId: data['senderId'],
//         receiverId: data['receiverId'] ?? _currentUserId ?? '',
//         isMe: data['senderId'] == _currentUserId,
//         timestamp: data['createdAt'] != null
//             ? DateTime.parse(data['createdAt'])
//             : DateTime.now(),
//         isSent: true,
//         isDelivered: data['delivered'] ?? false,
//       );

//       final List<Message> currentState = List<Message>.from(state);

//       // أ. إذا الرسالة موجودة مسبقاً بالـ ID الحقيقي، نحدثها فقط
//       final realIdIndex = currentState.indexWhere(
//         (msg) => msg.id == newMessage.id,
//       );
//       if (realIdIndex != -1) {
//         currentState[realIdIndex] = newMessage;
//         state = currentState;
//         return;
//       }

//       // ب. إذا كنت أنا المرسل، بنبحث عن الرسالة المؤقتة المستقرة بالـ State وبنحدثها بالـ ID الحقيقي فوراً
//       if (newMessage.isMe) {
//         final tempIdIndex = currentState.indexWhere(
//           (msg) =>
//               msg.id.startsWith("temp_") &&
//               msg.text.trim() == newMessage.text.trim(),
//         );

//         if (tempIdIndex != -1) {
//           currentState[tempIdIndex] =
//               newMessage; // استبدال المؤقت بالحقيقي بداخل الـ state نفسه!
//           state = currentState;
//           return;
//         }
//       }

//       // ج. إذا وصلنا هون، فهي رسالة جديدة من الطرف الآخر، ضيفها طبيعي
//       state = [...state, newMessage];
//     });
//   }

//   // 🌟 تعديل دالة الإرسال لتضيف الرسالة المؤقتة للـ State تبع ريفربرود فوراً
//   void sendMessageToSocket(String text, String receiverId) {
//     if (text.trim().isEmpty) return;

//     final now = DateTime.now();
//     final localId = "temp_${now.microsecondsSinceEpoch}";

//     final localMessage = Message(
//       id: localId,
//       text: text.trim(),
//       senderId: _currentUserId ?? '',
//       receiverId: receiverId,
//       isMe: true,
//       timestamp: now,
//       isSent: true,
//     );

//     // إضافة محلبة فورية بداخل ريفربرود ليكون مصدر الحقيقة الوحيد
//     state = [...state, localMessage];

//     // الإرسال للسوكت
//     _socketService.sendMessage(text.trim(), receiverId);
//   }

//   void connectSocket(String userId, String token) {
//     _currentUserId = userId;
//     _socketService.connect(token, userId);
//   }

//   void disconnectSocket() {
//     _socketService.disconnect();
//   }

//   /// يرسل عبر السوكت فقط ولا يتدخل بالـ state محلياً
//   /// (لأن شاشتك في نسخة الـ AnimatedList هي المسؤولية عن إدراج الـ temp_)

//   void editMessage(int index, String newText) {
//     if (index >= 0 && index < state.length) {
//       final updated = List<Message>.from(state);
//       updated[index] = updated[index].copyWith(text: newText, isEdited: true);
//       state = updated;
//     }
//   }

//   void deleteMessage(int index) {
//     if (index >= 0 && index < state.length) {
//       final updated = List<Message>.from(state);
//       updated.removeAt(index);
//       state = updated;
//     }
//   }

//   Future<void> fetchMessagesWithUser({
//     required String otherUserId,
//     int limit = 10,
//     int page = 1,
//   }) async {
//     try {
//       _isLoading = true;

//       final response = await _apiService.dio.get(
//         "/api/v1/messages/$otherUserId/?limit=$limit&page=$page",
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> messagesData = response.data['data']['messages'];

//         final List<Message> messages = messagesData.map((json) {
//           return Message(
//             id: json['_id'],
//             text: json['message'] ?? "",
//             senderId: json['senderId'],
//             receiverId: json['receiverId'],
//             isMe: json['senderId'] == _currentUserId,
//             timestamp: DateTime.parse(json['createdAt']),
//             isSent: true,
//             isDelivered: json['delivered'] ?? false,
//             isRead: json['read'] ?? false,
//           );
//         }).toList();

//         final sorted = messages.reversed.toList();

//         if (page == 1) {
//           state = sorted;
//         } else {
//           state = [...sorted, ...state];
//         }
//       }
//     } catch (e) {
//       print(" Error loading messages: $e");
//     } finally {
//       _isLoading = false;
//     }
//   }

//   Future<void> fetchNewMessages() async {
//     try {
//       final response = await _apiService.dio.get('/api/v1/messages/new');

//       if (response.statusCode == 200) {
//         final List<dynamic> messagesData = response.data['data']['newMessages'];
//         final List<Message> newMessages = messagesData.map((json) {
//           return Message(
//             id: json['id'].toString(),
//             text: json['text'] ?? '',
//             senderId: json['senderId'] ?? '',
//             receiverId: json['receiverId'] ?? '',
//             isMe: json['senderId'] == _currentUserId,
//             timestamp: DateTime.parse(json['createdAt']),
//             isSent: true,
//             isDelivered: json['delivered'] ?? false,
//             isRead: json['read'] ?? false,
//           );
//         }).toList();

//         final existingIds = state.map((m) => m.id).toSet();
//         final uniqueMessages = newMessages
//             .where((m) => !existingIds.contains(m.id))
//             .toList();

//         if (uniqueMessages.isNotEmpty) {
//           state = [...state, ...uniqueMessages];
//         }
//       }
//     } catch (e) {
//       print("❌ Error fetching new messages: $e");
//     }
//   }

//   Future<void> fetchLastMessageForContacts(List<String> contactIds) async {
//     if (contactIds.isEmpty || _currentUserId == null) return;

//     try {
//       final futures = contactIds.map((contactId) async {
//         try {
//           final response = await _apiService.dio.get(
//             "/api/v1/messages/$contactId/?limit=1&page=1",
//           );
//           if (response.statusCode == 200) {
//             final List<dynamic> data = response.data['data']['messages'];
//             if (data.isNotEmpty) {
//               final json = data.first;
//               return Message(
//                 id: json['_id'],
//                 text: json['message'] ?? "",
//                 senderId: json['senderId'],
//                 receiverId: json['receiverId'],
//                 isMe: json['senderId'] == _currentUserId,
//                 timestamp: DateTime.parse(json['createdAt']),
//                 isSent: true,
//                 isDelivered: json['delivered'] ?? false,
//                 isRead: json['read'] ?? false,
//               );
//             }
//           }
//         } catch (_) {}
//         return null;
//       }).toList();

//       final results = await Future.wait(futures);
//       final newMessages = results.whereType<Message>().toList();
//       if (newMessages.isEmpty) return;

//       final existingIds = state.map((m) => m.id).toSet();
//       final unique = newMessages
//           .where((m) => !existingIds.contains(m.id))
//           .toList();

//       if (unique.isNotEmpty) {
//         state = [...state, ...unique];
//       }
//     } catch (e) {
//       print(" Error fetching last messages: $e");
//     }
//   }

//   void clearMessages() {
//     state = [];
//   }

//   String? get currentUserId => _currentUserId;
// }
import 'package:flutter/material.dart';
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
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  @override
  List<Message> build() {
    final authState = ref.watch(authNotifierProvider);

    _currentUserId = authState.user?.id;

    if (_currentUserId != null) {
      _setupSocketListeners();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchNewMessages();
      });

      ref.onDispose(() {
        _socketService.offNewMessage();
      });
    }

    return [];
  }

  // void _setupSocketListeners() {
  //   // تنظيف أي listeners قديمة
  //   _socketService.offNewMessage();

  //   _socketService.onNewMessage((data) {
  //     if (data == null) return; // ← إضافة مهمة جداً
  //     if (_currentUserId == null) return;
  //     final newMessage = Message.fromSocket(data, _currentUserId!);
  //     ref
  //         .read(chatListNotifierProvider.notifier)
  //         .updateLastMessage(
  //           contactId: newMessage.senderId,
  //           message: newMessage,
  //         );

  //     // 2) إذا الرسالة موجودة مسبقاً بنفس الـ id → حدّثها واطلع
  //     final existingIndex = state.indexWhere((m) => m.id == newMessage.id);
  //     if (existingIndex != -1) {
  //       final updated = [...state];
  //       updated[existingIndex] = newMessage;
  //       state = updated;
  //       return;
  //     }

  //     // 3) إذا الرسالة منّي (isMe = true) → حاول تطابق temp_ وتستبدلها
  //     if (newMessage.isMe) {
  //       final tempIndex = state.indexWhere(
  //         (m) =>
  //             m.id.startsWith('temp_') &&
  //             m.text.trim() == newMessage.text.trim(),
  //       );

  //       if (tempIndex != -1) {
  //         final updated = [...state];
  //         updated[tempIndex] = newMessage;
  //         state = updated;
  //         return;
  //       }
  //     }

  //     // 4) إذا وصلنا لهون → رسالة جديدة (من الطرف الآخر غالباً) → أضفها
  //     state = [...state, newMessage];
  //   });
  // }
  // void _setupSocketListeners() {
  //   _socketService.offNewMessage();

  //   _socketService.onNewMessage((data) {
  //     if (data == null) return;
  //     if (_currentUserId == null) return;

  //     // 1) تحويل البيانات إلى Message
  //     final newMessage = Message.fromSocket(data, _currentUserId!);

  //     // 2) تحديث شاشة قائمة المحادثات
  //     ref
  //         .read(chatListNotifierProvider.notifier)
  //         .updateLastMessage(
  //           contactId: newMessage.senderId,
  //           message: newMessage,
  //         );

  //     // 3) إذا الرسالة موجودة مسبقاً → حدّثها
  //     final existingIndex = state.indexWhere((m) => m.id == newMessage.id);
  //     if (existingIndex != -1) {
  //       final updated = [...state];
  //       updated[existingIndex] = newMessage;
  //       state = updated;
  //       return;
  //     }

  //     // 4) إذا الرسالة منّي → استبدال temp_
  //     if (newMessage.isMe) {
  //       final tempIndex = state.indexWhere(
  //         (m) =>
  //             m.id.startsWith('temp_') &&
  //             m.text.trim() == newMessage.text.trim(),
  //       );

  //       if (tempIndex != -1) {
  //         final updated = [...state];
  //         updated[tempIndex] = newMessage;
  //         state = updated;
  //         return;
  //       }
  //     }

  //     // 5) إضافة الرسالة الجديدة
  //     state = [...state, newMessage];
  //   });
  // }
  void _setupSocketListeners() {
    // تنظيف أي listeners قديمة
    _socketService.offNewMessage();
    _socketService.offMessageSent();

    // -----------------------------
    // 🔥 1) استقبال رسالة جديدة من الطرف الآخر
    // -----------------------------
    _socketService.onNewMessage((data) {
      if (data == null) return;
      if (_currentUserId == null) return;

      final newMessage = Message.fromSocket(data, _currentUserId!);

      // إضافة contact إذا مش موجود
      final contacts = ref.read(contactsNotifierProvider);
      final exists = contacts.any((c) => c.id == newMessage.senderId);

      if (!exists) {
        ref
            .read(contactsNotifierProvider.notifier)
            .addContact(
              User(
                id: newMessage.senderId,
                userName: data['senderUserName'] ?? newMessage.senderId,
              ),
            );
      }

      // ❌ لا نحدّث الـ ChatList هون — ChatListNotifier يعمل ذلك تلقائياً

      // منطقك القديم كما هو
      final existingIndex = state.indexWhere((m) => m.id == newMessage.id);
      if (existingIndex != -1) {
        final updated = [...state];
        updated[existingIndex] = newMessage;
        state = updated;
        return;
      }

      state = [...state, newMessage];
    });

    // -----------------------------
    // 🔥 2) تأكيد إرسال الرسالة (messageSent)
    // -----------------------------
    _socketService.onMessageSent((data) {
      if (data == null) return;
      if (_currentUserId == null) return;

      final sentMessage = Message.fromSocket(data, _currentUserId!);

      // استبدال temp_ بالرسالة الحقيقية
      final tempIndex = state.indexWhere(
        (m) =>
            m.id.startsWith("temp_") &&
            m.text.trim() == sentMessage.text.trim(),
      );

      if (tempIndex != -1) {
        final updated = [...state];
        updated[tempIndex] = sentMessage;
        state = updated;
      } else {
        // إذا ما لقى temp_ → أضف الرسالة
        state = [...state, sentMessage];
      }

      // 🔥 تحديث شاشة قائمة المحادثات
      ref
          .read(chatListNotifierProvider.notifier)
          .addOrUpdateContact(
            contactId: sentMessage.receiverId,
            lastMessage: sentMessage,
          );
    });
  }

  // 🌟 تعديل دالة الإرسال لتضيف الرسالة المؤقتة للـ State تبع ريفربرود فوراً
  void sendMessageToSocket(String text, String receiverId) {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final tempId = "temp_${now.microsecondsSinceEpoch}";

    // 1) إنشاء رسالة مؤقتة
    final tempMessage = Message(
      id: tempId,
      text: text.trim(),
      senderId: _currentUserId ?? '',
      receiverId: receiverId,
      timestamp: now,
      isMe: true,
      isSent: false, // لأنها لسه مو مؤكدة من السيرفر
      isDelivered: false,
      isRead: false,
    );

    // 2) إضافتها للـ state فوراً
    state = [...state, tempMessage];

    // 3) إرسال الرسالة للسوكيت
    _socketService.sendMessage(text.trim(), receiverId);
  }

  void connectSocket(String userId, String token) {
    _currentUserId = userId;
    _socketService.connect(token, userId);
  }

  void disconnectSocket() {
    _socketService.disconnect();
  }

  /// يرسل عبر السوكت فقط ولا يتدخل بالـ state محلياً
  /// (لأن شاشتك في نسخة الـ AnimatedList هي المسؤولية عن إدراج الـ temp_)

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
      _isLoading = true;

      final response = await _apiService.dio.get(
        "/api/v1/messages/$otherUserId/?limit=$limit&page=$page",
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = response.data['data']['messages'];

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

  Future<void> fetchLastMessageForContacts(List<String> contactIds) async {
    if (contactIds.isEmpty || _currentUserId == null) return;

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

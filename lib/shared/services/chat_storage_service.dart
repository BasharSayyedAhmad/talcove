// shared/services/chat_storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:talcove/models/message.dart';

class ChatStorageService {
  static const String _messagesBox = 'chat_messages';

  late final Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_messagesBox);
  }

  // حفظ الرسائل لمحادثة معينة
  Future<void> saveMessages(String chatId, List<Message> messages) async {
    final key = _getKey(chatId);
    final messagesJson = messages.map((m) => m.toJson()).toList();
    await _box.put(key, messagesJson);
    print(" Saved ${messages.length} messages for chat: $chatId");
  }

  // جلب الرسائل لمحادثة معينة
  List<Message> getMessages(String chatId) {
    final key = _getKey(chatId);
    final data = _box.get(key);

    if (data == null) return [];

    final List<dynamic> messagesJson = data;
    final messages = messagesJson.map((json) {
      return Message.fromJson(Map<String, dynamic>.from(json));
    }).toList();

    print(
      "📖 Loaded ${messages.length} messages from local storage for chat: $chatId",
    );
    return messages;
  }

  // إضافة رسالة جديدة لمحادثة
  Future<void> addMessage(String chatId, Message message) async {
    final messages = getMessages(chatId);
    final updatedMessages = [...messages, message];
    await saveMessages(chatId, updatedMessages);
  }

  // مسح رسائل محادثة
  Future<void> clearMessages(String chatId) async {
    final key = _getKey(chatId);
    await _box.delete(key);
    print(" Cleared messages for chat: $chatId");
  }

  String _getKey(String chatId) => 'chat_$chatId';
}

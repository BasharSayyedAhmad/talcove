import 'package:hive_flutter/hive_flutter.dart';
import 'package:talcove/core/constants/app_settings_keys.dart';

class LocalStorageService {
  static const String _boxName = "TalcoveBox";
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get box => Hive.box(_boxName);
  static Future<void> clearAuthData() async {
    try {
      await box.deleteAll([
        sessionCookieKey,
        authMethodKey,
        userKey,
        contactsKey,
        lastSeenKey,
        pendingMessagesKey,
        socketSettingsKey,
        isTypingKey,
        messagesKey,
      ]);
      print(" Auth and User data cleared successfully from Hive");
    } catch (e) {
      print(" Error clearing auth data from Hive: $e");
    }
  }

  static Future<void> clearAll() async {
    try {
      await box.clear();
      print(" All Hive data cleared successfully");
    } catch (e) {
      print(" Error clearing all Hive data: $e");
    }
  }
}

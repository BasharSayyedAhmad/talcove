import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/constants/app_settings_keys.dart';
import 'package:talcove/core/services/notification_services.dart';
import 'package:talcove/core/services/user_service.dart';
import 'package:talcove/shared/services/local_storage_service.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  bool build() => _loadNotificationsFromHive();

  bool _loadNotificationsFromHive() {
    try {
      return LocalStorageService.box.get(
        notificationsEnabledKey,
        defaultValue: true,
      );
    } catch (e) {
      return true;
    }
  }

  Future<void> toggleNotifications(bool value) async {
    state = value;
    await LocalStorageService.box.put(notificationsEnabledKey, state);

    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(value);

      if (!value) {
        await UserService().updateDeviceToken(customToken: "");
      } else {
        await NotificationService().getDeviceToken();
      }
    } catch (e) {
      print('Error updating FCM token status: $e');
    }
  }
}

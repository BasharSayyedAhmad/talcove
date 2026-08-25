import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:talcove/core/services/navigation_services.dart';
import 'package:talcove/core/services/user_service.dart';
import 'package:talcove/features/chat/chat_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('[Background FCM] Received: ${message.messageId}');
  } catch (e) {
    debugPrint(' [Background FCM Error]: $e');
  }
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final UserService _userService = UserService();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

  Future<void> initialize() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    _fcm.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token refreshed: $newToken');
      await _userService.updateDeviceToken(customToken: newToken);
    });

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_androidChannel);
    }
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            _safeNavigateToChat(data);
          } catch (e) {
            debugPrint(' خطأ في فك تشفير بيانات الإشعار: $e');
          }
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(' وصل إشعار والتطبيق مفتوح: ${message.data}');

      RemoteNotification? notification = message.notification;

      _localNotifications.show(
        notification.hashCode,
        notification?.title ?? message.data['title'] ?? 'رسالة جديدة',
        notification?.body ??
            message.data['body'] ??
            message.data['message'] ??
            '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _safeNavigateToChat(message.data);
    });

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _safeNavigateToChat(initialMessage.data);
      });
    }
  }

  void _safeNavigateToChat(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToChat(data);
    });
  }

  void _navigateToChat(Map<String, dynamic> data) {
    final Map<String, dynamic>? senderObj =
        data['sender'] is Map<String, dynamic> ? data['sender'] : null;
    final Map<String, dynamic>? receiverObj =
        data['receiver'] is Map<String, dynamic> ? data['receiver'] : null;

    final String chatId =
        (data['chatId'] ?? data['chat_id'] ?? data['chat_room_id'] ?? '')
            .toString();

    String senderId =
        (senderObj?['id'] ??
                data['senderId'] ??
                data['sender_id'] ??
                data['userId'] ??
                data['user_id'] ??
                '')
            .toString();

    if (senderId.isEmpty && receiverObj != null) {
      senderId = (receiverObj['id'] ?? '').toString();
    }

    if (senderId.isEmpty && chatId.isNotEmpty) {
      senderId = chatId;
    }

    final String senderName =
        (senderObj?['senderUserName'] ??
                senderObj?['userName'] ??
                data['senderName'] ??
                data['sender_name'] ??
                data['title'] ??
                'مستخدم')
            .toString();

    final String rawPhoto =
        (senderObj?['profileImage'] ??
                data['profileImage'] ??
                data['profile_image'] ??
                data['user_photo'] ??
                '')
            .toString();

    final String? profileImage = (rawPhoto == 'null' || rawPhoto.isEmpty)
        ? null
        : rawPhoto;

    if (senderId.isNotEmpty) {
      NavigationService.push(
        ChatScreen(
          chatId: chatId,
          otherUserId: senderId,
          otherUserName: senderName,
          otherUserPhoto: profileImage,
        ),
      );
    } else {
      debugPrint(' البيانات القادمة من الإشعار غير مكتملة للانتقال: $data');
    }
  }

  Future<String?> getDeviceToken() async {
    final token = await _fcm.getToken();
    if (token != null && token.isNotEmpty) {
      debugPrint('Device Token Sent to Server: $token');
      await _userService.updateDeviceToken(customToken: token);
    }
    return token;
  }
}

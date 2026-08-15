import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:talcove/core/services/navigation_services.dart';
import 'package:talcove/features/chat/chat_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // معالجة الرسائل في الخلفية إذا لزم الأمر
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. طلب الصلاحيات
    await _fcm.requestPermission();

    // 2. تهيئة الإشعارات المحلية
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // عند كبس المستخدم على الإشعار المحلي والتطبيق مفتوح
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            _navigateToChat(data);
          } catch (e) {
            debugPrint('❌ خطأ في فك تشفير البيانات من الإشعار: $e');
          }
        }
      },
    );

    // 3. ربط معالج الخلفية لـ Firebase
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. استلام الإشعارات والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 5. النقر على الإشعار والتطبيق في الخلفية (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateToChat(message.data);
    });

    // 6. فتح التطبيق من حالة الإغلاق التام (Terminated) عبر النقر على الإشعار
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _navigateToChat(initialMessage.data);
    }
  }

  // دالة موحدة للتوجيه إلى شاشة المحادثة
  void _navigateToChat(Map<String, dynamic> data) {
    // 1. قراءة الهياكل المتداخلة من السوكت أو الـ Payload المعقد (sender/receiver)
    final Map<String, dynamic>? senderObj =
        data['sender'] is Map<String, dynamic> ? data['sender'] : null;
    final Map<String, dynamic>? receiverObj =
        data['receiver'] is Map<String, dynamic> ? data['receiver'] : null;

    // 2. استخراج معرف الغرفة بجميع التسميات الممكنة
    final String chatId =
        (data['chatId'] ?? data['chat_id'] ?? data['chat_room_id'] ?? '')
            .toString();

    // 3. استخراج senderId وتوفير البدائل عند غيابه من السيرفر
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

    // الاعتماد على chat_room_id كـ senderId مؤقت إذا أرسل السيرفر chat_room_id فقط
    if (senderId.isEmpty && chatId.isNotEmpty) {
      senderId = chatId;
    }

    // 4. استخراج اسم المستخدم
    final String senderName =
        (senderObj?['senderUserName'] ??
                senderObj?['userName'] ??
                data['senderName'] ??
                data['sender_name'] ??
                data['title'] ??
                'مستخدم')
            .toString();

    // 5. معالجة رابط الصورة وتجاهل قيم "null" النصية
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

    // 6. التوجيه للشاشة
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
      debugPrint('⚠️ البيانات القادمة من الإشعار غير مكتملة للانتقال: $data');
    }
  }

  // جلب رمز الجهاز (FCM Token)
  Future<String?> getDeviceToken() async {
    return await _fcm.getToken();
  }
}

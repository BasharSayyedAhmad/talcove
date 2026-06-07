import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// دالة التعامل مع الإشعارات في الخلفية أو عند إغلاق التطبيق تماماً
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📡 تم استقبال إشعار في الخلفية بنجاح: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'chat_notifications_channel',
    'Chat Notifications',
    description: 'This channel is used for real-time chat push notifications.',
    importance: Importance.max, // تضمن ظهور الإشعار كرأس منبثق في الأعلى
    playSound: true,
  );

  Future<void> initialize() async {
    // 1. طلب صلاحيات النظام لظهور التنبيهات
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print(' تم تفعيل صلاحيات الإشعارات بنجاح في النظام');
      await _fcm.subscribeToTopic('MessageMe1');
    }

    // 2. تهيئة وتحديد أيقونة الإشعارات المحلية
    const androidInit = AndroidInitializationSettings('b1');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationClick(response.payload);
      },
    );

    // 3. بناء وحقن قناة الصوت والأهمية داخل نظام الأندرويد
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // 4. ربط دالة معالجة الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. الاستماع للإشعارات والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      // 💡 تم تبسيط الشرط هنا بالاكتفاء بفحص وجود الإشعار لضمان استقرار الاستقبال دائماً
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: 'b1',
              importance: Importance
                  .max, // تضمن إجبار النظام على إظهاره بالكامل والتطبيق مفتوح
              priority: Priority.high,
              playSound: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
              presentBadge: true,
            ),
          ),
          payload: message.data['chat_room_id'],
        );
      }
    });

    // 6. تشغيل مستمعي النقرات والتوجيه
    _setupNotificationClickListeners();
  }

  void _setupNotificationClickListeners() async {
    // في حال كان مغلقاً تماماً وتم تشغيله عبر الضغط على الإشعار
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage.data['chat_room_id']);
    }

    // في حال كان في الخلفية وتم العودة إليه عبر الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data['chat_room_id']);
    });
  }

  // دالة التعامل مع الضغط لفتح الشات المستهدف برمجياً
  void _handleNotificationClick(String? chatRoomId) {
    if (chatRoomId != null) {
      print("🚀 يتم الآن التوجيه برمجياً إلى الغرفة المستهدفة: $chatRoomId");
      // يمكنك وضع كود الـ Navigator أو الـ Routing هنا مستقبلاً لفتح الشات تلقائياً
    }
  }

  // جلب التوكن الفريد للجهاز الحالي لحفظه بالفايرستور
  Future<String?> getDeviceToken() async {
    return await _fcm.getToken();
  }
}

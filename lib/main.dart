import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/authentication/entry_screen.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/core/services/notification_services.dart';
import 'package:talcove/core/themes/theme.dart';
import 'package:talcove/features/home/home_screen.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/features/providers/language_provider.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/features/providers/theme_provider.dart';
import 'package:talcove/shared/services/local_storage_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// دالة معالجة الإشعارات (للتطبيق في الخلفية)
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();

//   print("📱 رسالة خلفية من النوع: ${message.data}");

//   if (message.data.isNotEmpty) {
//     final String title = message.data['title'] ?? 'اشعار جديد';
//     final String body = message.data['body'] ?? '';

//     print("Title: $title");
//     print("Body: $body");
//   }
// }

void main() async {
  // تفعيل الربط الأساسي مع المحرك
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // الحفاظ على الشاشة الترحيبية مؤقتاً
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp();

  // الحل لمنع الـ ANR: تشغيل العمليات الثقيلة بالتوازي ومراقبتها دون حظر الخيط الرئيسي
  try {
    await Future.wait([
      LocalStorageService.init(),
      ApiService().init(),
    ]).timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        print(
          "⚠️ استغرق تحميل الخدمات وقتاً أطول من المتوقع، سيتم المتابعة لتجنب تجميد التطبيق",
        );
        return [];
      },
    );

    // تشغيل خدمة الإشعارات بشكل منفصل ومحمي تماماً
    try {
      await NotificationService().initialize();
    } catch (e) {
      print("⚠️ خطأ غير مؤثر في تهيئة الإشعارات: $e");
    }
  } catch (e) {
    print("Error during parallel initialization: $e");
  }

  //   طلب إذن الإشعارات
  // await _requestPermission();

  //   الحصول على الـ Token
  // final token = await FirebaseMessaging.instance.getToken();
  // print(" FCM token: $token");

  // لما يكون التطبيق مفتوح
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print(" Foreground notification: ${message.notification?.title}");
  //   // عرض الإشعار محلياً
  //   _showLocalNotification(message);
  // });

  // إزالة الشاشة الترحيبية فوراً لمنع الأندرويد من الشك في وجود تجميد
  FlutterNativeSplash.remove();

  runApp(const ProviderScope(child: MyApp()));
}

//   طلب الإذن لاجهزة اندرويد 13 وما فوق
// Future<void> _requestPermission() async {
//   final settings = await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//   print("📱 Notification permission: ${settings.authorizationStatus}");
// }

//   عرض إشعار محلي عندما يكون التطبيق مفتوحاً
// void _showLocalNotification(RemoteMessage message) {
//   print("Title: ${message.notification?.title}");
//   print("Body: ${message.notification?.body}");
// }

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final language = ref.watch(languageNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      home: authState.isAuthenticated
          ? const HomeScreen()
          : const EntryScreen(),
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightMode,
      darkTheme: darkMode,
      locale: language,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}

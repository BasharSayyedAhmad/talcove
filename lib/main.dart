import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/authentication/entry_screen.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/core/services/navigation_services.dart';
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

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await LocalStorageService.init();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  if (!kIsWeb) {
    Future.microtask(() async {
      await ApiService().init();
      await NotificationService().initialize();
    });
  }
  FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(authNotifierProvider.notifier).restoreSession();
      if (!kIsWeb && ref.read(authNotifierProvider).isAuthenticated) {
        await NotificationService().getDeviceToken();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final language = ref.watch(languageNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
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

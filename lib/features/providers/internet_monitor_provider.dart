import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:talcove/core/services/internet_service.dart';
import 'package:talcove/features/providers/auth_provider.dart';

final internetMonitorProvider =
    StateNotifierProvider<InternetMonitorNotifier, InternetMonitorState>((ref) {
      return InternetMonitorNotifier(ref);
    });

class InternetMonitorState {
  final bool hasInternet;
  final ConnectivityResult connectionType;

  const InternetMonitorState({
    required this.hasInternet,
    this.connectionType = ConnectivityResult.none,
  });

  factory InternetMonitorState.initial() {
    return const InternetMonitorState(
      hasInternet: true,
      connectionType: ConnectivityResult.wifi,
    );
  }

  InternetMonitorState copyWith({
    bool? hasInternet,
    ConnectivityResult? connectionType,
  }) {
    return InternetMonitorState(
      hasInternet: hasInternet ?? this.hasInternet,
      connectionType: connectionType ?? this.connectionType,
    );
  }
}

class InternetMonitorNotifier extends StateNotifier<InternetMonitorState> {
  final Ref ref;
  late final StreamSubscription<ConnectivityResult> _subscription;

  Timer? _pollingTimer;
  final InternetService _internetService = InternetService();

  InternetMonitorNotifier(this.ref) : super(InternetMonitorState.initial()) {
    _init();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final hasRealInternet = await _internetService.hasInternet();
      final previousState = state.hasInternet;

      if (previousState != hasRealInternet) {
        print("Polling detected change: $hasRealInternet");

        state = state.copyWith(hasInternet: hasRealInternet);

        final authNotifier = ref.read(authNotifierProvider.notifier);
        authNotifier.updateInternetStatus(hasRealInternet);

        if (!previousState && hasRealInternet) {
          await _onInternetRestored();
        }
      }
    });
  }

  Future<void> _init() async {
    await checkInternet();

    _subscription = _internetService.onConnectivityChanged.listen((
      ConnectivityResult result,
    ) async {
      print("onConnectivityChanged FIRED with: $result");

      final previousState =
          state.hasInternet; // الحفاظ على الحالة السابقة قبل التحديث
      final hasRealInternet = await _internetService.hasInternet();

      print("hasRealInternet: $hasRealInternet");
      print("previousState: $previousState");

      final connectionType = result;

      // 1. تحديث حالة الـ Monitor كـ UI أولاً
      state = state.copyWith(
        hasInternet: hasRealInternet,
        connectionType: connectionType,
      );

      print("state.hasInternet after update: ${state.hasInternet}");

      // 2. 🛡️ الفحص الذكي والآمن لمنع التكرار والـ Race Condition:
      // لا نطلب تحديث الـ Socket والـ Session إلا إذا تغيرت حالة الإنترنت الفعلية (مثلاً من قطع لاتصال أو العكس)
      if (previousState != hasRealInternet) {
        print(
          "🌐 Internet status changed from $previousState to $hasRealInternet. Updating Auth...",
        );

        final authNotifier = ref.read(authNotifierProvider.notifier);
        authNotifier.updateInternetStatus(hasRealInternet);

        if (!previousState && hasRealInternet) {
          await _onInternetRestored();
        }
      } else {
        // إذا انضربت الدالة عند الإقلاع والإنترنت متصل أصلاً (true -> true)، سيتخطى استدعاء السوكيت المكرر بسلام
        print(
          "ℹ️ Internet status remains unchanged ($hasRealInternet). Skipping redundant socket update.",
        );
      }
    });
    print("Called updateInternetStatus successfully");
  }

  Future<void> checkInternet() async {
    final hasRealInternet = await _internetService.hasInternet();
    final connectionType = await _internetService.connectivityResult;

    state = state.copyWith(
      hasInternet: hasRealInternet,
      connectionType: connectionType,
    );
  }

  Future<void> _onInternetRestored() async {
    print("Internet restored - refreshing session automatically");
    // تم حذف استدعاء updateInternetStatus الزائد هنا لأن الدالة الأب أصبحت تستدعيه بشكل صحيح عند تحقق الشرط
  }

  @override
  void dispose() {
    _subscription.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }
}

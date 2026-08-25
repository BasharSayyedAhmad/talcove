import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:talcove/core/services/internet_service.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/shared/services/socket_service.dart';

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
  late final _AppLifecycleObserver _lifecycleObserver;

  InternetMonitorNotifier(this.ref) : super(InternetMonitorState.initial()) {
    _init();
    _startPolling();
    _lifecycleObserver = _AppLifecycleObserver(
      onPause: () {
        print("🔌 App in background: Disconnecting socket...");
        SocketService().disconnect();
      },
      onResume: () {
        print("⚡ App resumed: Reconnecting socket...");
        if (state.hasInternet) {
          SocketService().reconnect();
        }
      },
    );

    WidgetsBinding.instance.addObserver(_lifecycleObserver);
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

      final previousState = state.hasInternet;
      final hasRealInternet = await _internetService.hasInternet();

      print("hasRealInternet: $hasRealInternet");
      print("previousState: $previousState");

      final connectionType = result;

      state = state.copyWith(
        hasInternet: hasRealInternet,
        connectionType: connectionType,
      );

      print("state.hasInternet after update: ${state.hasInternet}");

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _subscription.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }
}

class _AppLifecycleObserver with WidgetsBindingObserver {
  final VoidCallback onPause;
  final VoidCallback onResume;

  _AppLifecycleObserver({required this.onPause, required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      onPause();
    } else if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}

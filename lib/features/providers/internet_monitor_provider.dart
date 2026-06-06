// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:talcove/core/services/internet_service.dart';
// import 'package:talcove/features/providers/auth_provider.dart';

// final internetMonitorProvider =
//     StateNotifierProvider<InternetMonitorNotifier, InternetMonitorState>((ref) {
//       return InternetMonitorNotifier(ref);
//     });

// class InternetMonitorState {
//   final bool hasInternet;
//   final ConnectivityResult connectionType;

//   const InternetMonitorState({
//     required this.hasInternet,
//     this.connectionType = ConnectivityResult.none,
//   });

//   factory InternetMonitorState.initial() {
//     return const InternetMonitorState(
//       hasInternet: true,
//       connectionType: ConnectivityResult.wifi,
//     );
//   }

//   InternetMonitorState copyWith({
//     bool? hasInternet,
//     ConnectivityResult? connectionType,
//   }) {
//     return InternetMonitorState(
//       hasInternet: hasInternet ?? this.hasInternet,
//       connectionType: connectionType ?? this.connectionType,
//     );
//   }
// }

// class InternetMonitorNotifier extends StateNotifier<InternetMonitorState> {
//   final Ref ref;
//   late final StreamSubscription<ConnectivityResult> _subscription; // ✅ تغيير 1
//   final InternetService _internetService = InternetService();

//   InternetMonitorNotifier(this.ref) : super(InternetMonitorState.initial()) {
//     _init();
//   }

//   Future<void> _init() async {
//     await checkInternet();

//     _subscription = _internetService.onConnectivityChanged.listen((
//       ConnectivityResult result,
//     ) async {
//       // ✅ تغيير 2
//       final previousState = state.hasInternet;
//       final hasRealInternet = await _internetService.hasInternet();
//       final connectionType = result; // ✅ تغيير 3

//       print(
//         "📡 Internet status changed: ${hasRealInternet ? 'Connected' : 'Disconnected'} - Type: $connectionType",
//       );

//       state = state.copyWith(
//         hasInternet: hasRealInternet,
//         connectionType: connectionType,
//       );

//       if (!previousState && hasRealInternet) {
//         await _onInternetRestored();
//       }
//     });
//   }

//   Future<void> checkInternet() async {
//     final hasRealInternet = await _internetService.hasInternet();
//     final connectionType = await _internetService.connectivityResult;

//     state = state.copyWith(
//       hasInternet: hasRealInternet,
//       connectionType: connectionType,
//     );
//   }

//   Future<void> _onInternetRestored() async {
//     print("🌐 Internet restored - refreshing session automatically");

//     final authNotifier = ref.read(authNotifierProvider.notifier);
//     authNotifier.updateInternetStatus(true);
//   }

//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
// }

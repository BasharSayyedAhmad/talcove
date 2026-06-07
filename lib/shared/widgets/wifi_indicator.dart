// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:talcove/features/providers/auth_provider.dart';
// import 'package:talcove/features/providers/internet_monitor_provider.dart';

// class WifiIndicator extends ConsumerWidget {
//   final bool showLabel;
//   final double iconSize;

//   const WifiIndicator({super.key, this.showLabel = false, this.iconSize = 24});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final internetState = ref.watch(internetMonitorProvider);
//     final authState = ref.watch(authNotifierProvider);

//     if (!internetState.hasInternet && authState.isAuthenticated) {
//       return Tooltip(
//         message: 'لا يوجد اتصال بالإنترنت - سيتم التحديث تلقائياً',
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.wifi_off, color: Colors.red, size: iconSize),
//             if (showLabel) ...[
//               const SizedBox(width: 4),
//               const Text(
//                 'غير متصل',
//                 style: TextStyle(color: Colors.red, fontSize: 12),
//               ),
//             ],
//           ],
//         ),
//       );
//     }

//     return const SizedBox.shrink();
//   }
// }

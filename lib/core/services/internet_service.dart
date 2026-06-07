// import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';

// class InternetService {
//   static final InternetService _instance = InternetService._internal();
//   factory InternetService() => _instance;
//   InternetService._internal();
//   final Connectivity _connectivity = Connectivity();
//   Future<bool> hasInternet() async {
//     try {
//       final result = await InternetAddress.lookup("google.com");
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       return false;
//     }
//   }

//   Stream<ConnectivityResult> get onConnectivityChanged =>
//       _connectivity.onConnectivityChanged.map((event) => event.first);
//   Future<ConnectivityResult> get connectivityResult async =>
//       await _connectivity.checkConnectivity().then((value) => value.first);
// }

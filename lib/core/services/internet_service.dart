import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class InternetService {
  static final InternetService _instance = InternetService._internal();
  factory InternetService() => _instance;
  InternetService._internal();
  final Connectivity _connectivity = Connectivity();
  Future<bool> hasInternet() async {
    print(" hasInternet() CALLED ");
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      final hasNet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      print(" hasInternet() result: $hasNet");
      return hasNet;
    } on SocketException catch (e) {
      print(" hasInternet() SocketException: $e");
      return false;
    } on TimeoutException catch (e) {
      print(" hasInternet() TimeoutException: $e");
      return false;
    }
  }

  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map((event) => event.first);
  Future<ConnectivityResult> get connectivityResult async =>
      await _connectivity.checkConnectivity().then((value) => value.first);
  // استماع بعد انقطاع الانرتنت
  Stream<bool> get onInternetRestored => onConnectivityChanged
      .where((result) {
        return result != ConnectivityResult.none;
      })
      .asyncMap((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return await hasInternet();
      })
      .where((hasNet) => hasNet == true);
}

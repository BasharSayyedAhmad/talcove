import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox("TalcoveBox");
  }

  static Box get box => Hive.box("TalcoveBox");
}

import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox("TalcoveBox");
  }

  static Future<void> clearAll() async {
    await box.clear();
    await box.close();

    await Hive.deleteBoxFromDisk("TalcoveBox");
    await Hive.openBox("TalcoveBox");
    print(" All Hive data cleared");
  }

  static Box get box => Hive.box("TalcoveBox");
}

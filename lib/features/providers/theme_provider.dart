import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/constants/app_settings_keys.dart';
import 'package:talcove/shared/services/local_storage_service.dart';
part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() => _loadThemeFromhive();
  ThemeMode _loadThemeFromhive() {
    try {
      final themeIndex = LocalStorageService.box.get(
        themeModeKey,
        defaultValue: 2,
      );
      switch (themeIndex) {
        case 0:
          return ThemeMode.dark;
        case 1:
          return ThemeMode.light;
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      return ThemeMode.system;
    }
  }

  void _saveThemeToHive(ThemeMode themeMode) {
    int themeIndex;
    switch (themeMode) {
      case ThemeMode.dark:
        themeIndex = 0;
        break;
      case ThemeMode.light:
        themeIndex = 1;
        break;
      case ThemeMode.system:
        themeIndex = 2;
        break;
    }
    LocalStorageService.box.put(themeModeKey, themeIndex);
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
    _saveThemeToHive(state);
  }
}

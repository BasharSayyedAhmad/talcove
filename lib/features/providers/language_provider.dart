import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/constants/app_settings_keys.dart';
import 'package:talcove/shared/services/local_storage_service.dart';
part 'language_provider.g.dart';

@riverpod
class LanguageNotifier extends _$LanguageNotifier {
  @override
  Locale build() => _loadLanguageFromHive();

  Locale _loadLanguageFromHive() {
    try {
      final languageIndex = LocalStorageService.box.get(
        languageKey,
        defaultValue: 0,
      );
      switch (languageIndex) {
        case 0:
          return const Locale('en');
        case 1:
          return const Locale('ar');
        case 2:
          return const Locale('fr');
        default:
          return const Locale('en');
      }
    } catch (e) {
      return const Locale('en');
    }
  }

  void _saveLanguageToHive(Locale locale) {
    int languageIndex;
    switch (locale.languageCode) {
      case 'en':
        languageIndex = 0;
        break;
      case 'ar':
        languageIndex = 1;
        break;
      case 'fr':
        languageIndex = 2;
        break;
      default:
        languageIndex = 0;
    }
    LocalStorageService.box.put(languageKey, languageIndex);
  }

  void changeLanguage(Locale newLocale) {
    state = newLocale;
    _saveLanguageToHive(newLocale);
  }
}

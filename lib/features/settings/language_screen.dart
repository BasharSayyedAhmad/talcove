import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/providers/language_provider.dart';
import 'package:talcove/generated/l10n.dart';

class LanguageWidget extends ConsumerWidget {
  const LanguageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageNotifierProvider);
    final languageNotifier = ref.read(languageNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).language)),
      body: Card(
        color: Colors.blueGrey[900],
        child: ListView(
          children: [
            RadioListTile<Locale>(
              value: const Locale('ar'),
              groupValue: currentLocale,
              title: const Text("العربية"),
              subtitle: const Text("Arabic"),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  languageNotifier.changeLanguage(newLocale);
                }
              },
            ),
            const Divider(),
            RadioListTile<Locale>(
              value: const Locale('en'),
              groupValue: currentLocale,
              title: const Text("English"),
              subtitle: const Text("English"),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  languageNotifier.changeLanguage(newLocale);
                }
              },
            ),
            const Divider(),
            RadioListTile<Locale>(
              value: const Locale('fr'),
              groupValue: currentLocale,
              title: const Text("Français"),
              subtitle: const Text("French"),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  languageNotifier.changeLanguage(newLocale);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/providers/language_provider.dart';

class LanguageIcon extends ConsumerWidget {
  const LanguageIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.read(languageNotifierProvider.notifier);

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: (val) {
        language.changeLanguage(val);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: Locale('en'), child: Text("English")),

        const PopupMenuItem(value: Locale('ar'), child: Text("العربية")),

        const PopupMenuItem(value: Locale('fr'), child: Text("Français")),
      ],
    );
  }
}

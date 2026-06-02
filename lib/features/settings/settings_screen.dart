import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/authentication/entry_screen.dart';
import 'package:talcove/features/profile/profile_screen.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/features/providers/language_provider.dart';
import 'package:talcove/features/providers/theme_provider.dart';
import 'package:talcove/features/settings/language_screen.dart';
import 'package:talcove/generated/l10n.dart';

String _getCurrentLanguageName(WidgetRef ref) {
  final currentLocale = ref.watch(languageNotifierProvider);
  switch (currentLocale.languageCode) {
    case 'ar':
      return 'العربية';
    case 'en':
      return 'English';
    case 'fr':
      return 'Français';
    default:
      return 'English';
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    final user = authState.user;
    final userName = user?.userName ?? "";
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surface,
            elevation: 6,
            shadowColor: Colors.white,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                ),
                Text(userName),
                Text("@$userName"),
                const Divider(indent: 12, endIndent: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [Text("1.2k"), Text("Messages")]),
                    Column(
                      children: [
                        Text("84", style: TextStyle(color: Colors.teal)),
                        Text("Stories"),
                      ],
                    ),
                    Column(
                      children: [
                        Text("4.9", style: TextStyle(color: Colors.pinkAccent)),
                        Text("Rating"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(S.of(context).theme, style: TextStyle(fontSize: 20)),
          Card(
            child: SwitchListTile(
              value: theme == ThemeMode.dark,
              onChanged: (val) {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
              title: Text(S.of(context).dark),
            ),
          ),

          Text(S.of(context).language, style: const TextStyle(fontSize: 20)),
          Card(
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LanguageWidget()),
                );
              },
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              title: Text(S.of(context).language),
              subtitle: Text(
                _getCurrentLanguageName(ref),
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
            ),
          ),
          Text(S.of(context).account, style: TextStyle(fontSize: 20)),

          Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  leading: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  title: Text(S.of(context).profile),
                  subtitle: const Text("Username, email, bio"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                ),
                const Divider(),
                ListTile(
                  onTap: () {},
                  title: Text(S.of(context).notifications),
                  subtitle: const Text("Sound, Vibratrion, alert"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                ),
                const Divider(),
                ListTile(
                  onTap: () async {
                    ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const EntryScreen()),
                      );
                    }
                  },

                  title: Text(
                    S.of(context).logOut,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(S.of(context).SignOutOfYourAccount),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// lib/features/settings/settings_screen.dart
import 'package:flutter/cupertino.dart';
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
    ref.listen(authNotifierProvider, (prev, next) {
      if (!next.isAuthenticated && prev?.isAuthenticated == true) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const EntryScreen()),
          (route) => false,
        );
      }
    });
    final theme = ref.watch(themeNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = _getCurrentLanguageName(ref);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: colorScheme.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              S.of(context).settings,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 19,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: colorScheme.surface,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: colorScheme.error,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Log out',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (val) {
                  if (val == 'logout') {
                    // ref.read(authNotifierProvider.notifier).logout();
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _UserHeaderCard(
                user: user,
                colorScheme: colorScheme,
                isDark: isDark,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionHeader(label: 'Account', colorScheme: colorScheme),
                const SizedBox(height: 8),
                _SettingsCard(
                  colorScheme: colorScheme,
                  isDark: isDark,
                  items: [
                    _SettingsTile(
                      icon: Icons.person_rounded,
                      iconColor: colorScheme.primary,
                      title: S.of(context).profile,
                      subtitle: 'Name, photo, bio',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ),
                      colorScheme: colorScheme,
                    ),
                    _TileDivider(colorScheme: colorScheme),
                    _SettingsTile(
                      icon: Icons.shield_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: S.of(context).privacySettings,
                      subtitle: 'Email, phone, visibility',
                      onTap: () {},
                      colorScheme: colorScheme,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _SectionHeader(label: 'Preferences', colorScheme: colorScheme),
                const SizedBox(height: 8),
                _SettingsCard(
                  colorScheme: colorScheme,
                  isDark: isDark,
                  items: [
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: S.of(context).notifications,
                      subtitle: 'Sound, vibration, alerts',
                      onTap: () {},
                      colorScheme: colorScheme,
                    ),
                    _TileDivider(colorScheme: colorScheme),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: S.of(context).language,
                      subtitle: currentLang,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LanguageWidget(),
                        ),
                      ),
                      colorScheme: colorScheme,
                    ),
                    _TileDivider(colorScheme: colorScheme),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color:
                                  (isDark
                                          ? const Color(0xFF818CF8)
                                          : const Color(0xFF6366F1))
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              size: 20,
                              color: isDark
                                  ? const Color(0xFF818CF8)
                                  : const Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).dark,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  isDark ? 'Dark mode on' : 'Light mode on',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: theme == ThemeMode.dark,
                            activeTrackColor: colorScheme.primary,
                            onChanged: (_) => ref
                                .read(themeNotifierProvider.notifier)
                                .toggleTheme(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // زر تسجيل الخروج
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("log out"),
                          content: Text("Are you sure you want to log out"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                ref
                                    .read(authNotifierProvider.notifier)
                                    .logout(context);
                              },
                              child: Text(
                                "Log out",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: authState.isLoading
                      ? const CupertinoActivityIndicator()
                      : Icon(Icons.logout_rounded, color: colorScheme.error),
                  label: Text(
                    S.of(context).logOut,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserHeaderCard extends StatelessWidget {
  final dynamic user;
  final ColorScheme colorScheme;
  final bool isDark;

  const _UserHeaderCard({
    required this.user,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: !isDark
              ? [colorScheme.primary, colorScheme.tertiary]
              : const [
                  Color.fromARGB(255, 26, 35, 126),
                  Color.fromARGB(255, 57, 73, 171),
                ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? const Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.userName ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (user?.email != null)
                    Text(
                      user!.email!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;

  const _SectionHeader({required this.label, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isDark;
  final List<Widget> items;

  const _SettingsCard({
    required this.colorScheme,
    required this.isDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(children: items),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  final ColorScheme colorScheme;
  const _TileDivider({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 68,
      color: colorScheme.onSurface.withValues(alpha: 0.06),
    );
  }
}

// lib/features/profile/privacy_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/generated/l10n.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  late bool _isEmailVisible;
  late bool _isPhoneVisible;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _isEmailVisible = user?.isEmailVisible ?? false;
    _isPhoneVisible = user?.isPhoneNumberVisible ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).privacySettings),
        backgroundColor: colorScheme.primary,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              SwitchListTile(
                title: Text(S.of(context).showEmail),
                subtitle: Text(S.of(context).whoCanSeeEmail),
                value: _isEmailVisible,
                onChanged: (value) {
                  setState(() => _isEmailVisible = value);
                  _saveChanges();
                },
              ),
              const Divider(),
              SwitchListTile(
                title: Text(S.of(context).showPhoneNumber),
                subtitle: Text(S.of(context).whoCanSeePhone),
                value: _isPhoneVisible,
                onChanged: (value) {
                  setState(() => _isPhoneVisible = value);
                  _saveChanges();
                },
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    await ref
        .read(authNotifierProvider.notifier)
        .updatePrivacySettings(
          emailVisible: _isEmailVisible,
          phoneVisible: _isPhoneVisible,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Privacy settings updated')));
    }
  }
}

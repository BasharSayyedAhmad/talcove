import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/authentication/entry_screen.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/models/auth_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final userName = authState.user?.userName ?? "";
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (!next.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EntryScreen()),
        );
      }
    });
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            ref.read(authNotifierProvider.notifier).logout();
          },
          icon: user?.photoUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(user!.photoUrl!),
                  radius: 12,
                )
              : const Icon(Icons.person),
          label: const Text(""),
        ),
      ),
    );
  }
}

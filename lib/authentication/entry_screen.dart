import 'package:flutter/material.dart';
import 'package:talcove/authentication/signup_screen.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/shared/widgets/custom_button.dart';
import 'package:talcove/shared/widgets/theme_icon.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Talcove"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: const [ThemeIcon()],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsetsGeometry.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              onPressed: () {},
              child: Text(
                S.of(context).login,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),
            CustomButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              child: Text(
                S.of(context).signup,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

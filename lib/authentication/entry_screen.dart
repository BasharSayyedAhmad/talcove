import 'package:flutter/material.dart';
import 'package:talcove/authentication/login_screen.dart';
import 'package:talcove/authentication/signup_screen.dart';
import 'package:talcove/core/constants/app_breakpoints.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/shared/widgets/custom_button.dart';
import 'package:talcove/shared/widgets/language_icon.dart';
import 'package:talcove/shared/widgets/theme_icon.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppBreakpoints.tablet;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.background, cs.surface.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Top icons
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        LanguageIcon(),
                        SizedBox(width: 12),
                        ThemeIcon(),
                      ],
                    ),

                    const Spacer(),

                    // Logo
                    Image.asset(
                      "assets/images/talcove_logo.png",
                      width: isMobile ? 130 : 170,
                      height: isMobile ? 130 : 170,
                    ),

                    const SizedBox(height: 20),

                    // Subtitle
                    Text(
                      "Connect • Share • Discover",
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 20,
                        color: cs.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login button
                    CustomButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: Text(
                        S.of(context).login,
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 26,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Signup button
                    CustomButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                      child: Text(
                        S.of(context).signup,
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 26,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Text(
                      "© 2026 Talcove",
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

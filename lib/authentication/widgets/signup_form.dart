import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/authentication/widgets/confirm_password_field.dart';
import 'package:talcove/authentication/widgets/password_field.dart';
import 'package:talcove/core/constants/app_breakpoints.dart';
import 'package:talcove/core/constants/app_dimensions.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/features/providers/language_provider.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/shared/widgets/custom_text.dart';

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.validateKey,
  });
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> validateKey;

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  bool _showText = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showText = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = AppDimensions.screenHeight(context);
    final width = AppDimensions.screenWidth(context);
    final isMobile = width < AppBreakpoints.tablet;
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final languageNotifier = ref.read(languageNotifierProvider.notifier);

    return Stack(
      children: [
        Align(
          alignment: languageNotifier.isArabic()
              ? Alignment.topRight
              : Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              iconSize: 20,
              color: Theme.of(context).colorScheme.onSecondary,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        SizedBox(
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/talcove_logo.png",
                width: isMobile ? 130 : 170,
                height: isMobile ? 130 : 170,
              ),
              const SizedBox(height: 20),
              Text(
                S.of(context).createYourAccount,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              CustomText(
                controller: widget.usernameController,
                hintText: S.of(context).UserName,
                prefixIcon: const Icon(Icons.person),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter your user name!";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),
              PasswordFiled(passwordController: widget.passwordController),
              const SizedBox(height: 10),
              ConfirmPassword(
                passwordController: widget.passwordController,
                confirmController: widget.confirmPasswordController,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.validateKey.currentState!.validate()) {
                      await authNotifier.signUpWithUserNameAndPassword(
                        widget.usernameController.text.trim(),
                        widget.passwordController.text,
                      );
                    }
                  },
                  child: Text(
                    S.of(context).signup,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Divider(indent: 5, thickness: 1, endIndent: 5),
                  ),
                  Text(S.of(context).orSignUpWith),
                  const Expanded(
                    child: Divider(indent: 5, thickness: 1, endIndent: 5),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  authNotifier.loginWithGoogle();
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/g_logo.png",
                        width: 25,
                        height: 25,
                      ),
                      const SizedBox(width: 5),
                      AnimatedCrossFade(
                        firstChild: const SizedBox(),
                        secondChild: Text(S.of(context).continueWithGoogle),
                        crossFadeState: _showText
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

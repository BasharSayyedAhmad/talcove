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

class SignupForm extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
              icon: const Icon(Icons.close),
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
                controller: usernameController,
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
              CustomText(
                controller: emailController,
                hintText: S.of(context).email,
                prefixIcon: const Icon(Icons.email),
              ),
              const SizedBox(height: 10),
              PasswordFiled(passwordController: passwordController),
              const SizedBox(height: 10),
              ConfirmPassword(
                passwordController: passwordController,
                confirmController: confirmPasswordController,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ElevatedButton(
                  onPressed: () async {
                    if (validateKey.currentState!.validate()) {
                      await authNotifier.signUpWithUserNameAndPassword(
                        usernameController.text.trim(),
                        passwordController.text,
                        emailController.text.trim(),
                      );
                    }
                  },
                  child: Text(
                    S.of(context).signup,
                    style: const TextStyle(fontSize: 20),
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
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/g_logo.png",
                      width: 25,
                      height: 25,
                    ),
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

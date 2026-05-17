import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/authentication/signup_screen.dart';
import 'package:talcove/authentication/widgets/password_field.dart';
import 'package:talcove/core/constants/app_breakpoints.dart';
import 'package:talcove/core/constants/app_dimensions.dart';
import 'package:talcove/core/utils/validators.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/features/providers/language_provider.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/shared/widgets/custom_text.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({
    super.key,
    required this.userNameController,
    required this.passwordController,
    required this.validatorKey,
  });
  final TextEditingController userNameController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> validatorKey;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
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
          height: AppDimensions.screenHeight(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/talcove_logo.png",
                width: isMobile ? 130 : 170,
                height: isMobile ? 130 : 170,
              ),
              // SizedBox(height: isMobile ? height * 0.15 : height * 0.2),
              Text(
                S.of(context).welcomeBack,
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context).loginToYourAccount,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),

              CustomText(
                controller: widget.userNameController,
                hintText: S.of(context).UserName,
                prefixIcon: const Icon(Icons.person),
                validator: (val) => Validators.username(context, val),
              ),
              const SizedBox(height: 10),

              PasswordFiled(passwordController: widget.passwordController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (widget.validatorKey.currentState!.validate()) {
                    ref
                        .read(authNotifierProvider.notifier)
                        .loginWithUserNameAndPassword(
                          widget.userNameController.text.trim(),
                          widget.passwordController.text,
                        );
                  }
                },
                child: Text(
                  S.of(context).signin,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerColor,
                      thickness: 1,
                      indent: 6,
                      endIndent: 6,
                    ),
                  ),
                  Text(S.of(context).orSigninWith),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerColor,
                      thickness: 1,
                      indent: 6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ? const Center(child: RefreshProgressIndicator())
              // ? const Center(child: LinearProgressIndicator())
              InkWell(
                onTap: () {
                  authNotifier.loginWithGoogle();
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(S.of(context).DontHaveAccount),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: Text(S.of(context).signup),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

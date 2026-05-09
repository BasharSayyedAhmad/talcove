import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/authentication/widgets/password_field.dart';
import 'package:talcove/core/constants/app_breakpoints.dart';
import 'package:talcove/core/constants/app_dimensions.dart';
import 'package:talcove/core/utils/validators.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/shared/widgets/custom_text.dart';

class LoginForm extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final height = AppDimensions.screenHeight(context);
    final width = AppDimensions.screenWidth(context);
    final isMobile = width < AppBreakpoints.tablet;
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: isMobile ? height * 0.15 : height * 0.2),
        Text(
          S.of(context).loginToYourAccount,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        CustomText(
          controller: userNameController,
          hintText: S.of(context).UserName,
          prefixIcon: const Icon(Icons.person),
          validator: (val) => Validators.username(context, val),
        ),
        const SizedBox(height: 10),

        PasswordFiled(passwordController: passwordController),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (validatorKey.currentState!.validate()) {
              ref
                  .read(authNotifierProvider.notifier)
                  .loginWithUserNameAndPassword(
                    userNameController.text.trim(),
                    passwordController.text,
                  );
            }
          },
          child: Text(
            S.of(context).signin,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: Colors.amber,
                thickness: 1,
                indent: 6,
                endIndent: 6,
              ),
            ),
            Text(S.of(context).orSigninWith),
            const Expanded(
              child: Divider(color: Colors.amber, thickness: 1, indent: 6),
            ),
          ],
        ),
        const SizedBox(height: 10),

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
                  color: Colors.black.withOpacity(0.6),
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
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(S.of(context).DontHaveAccount),
            TextButton(onPressed: () {}, child: Text(S.of(context).signup)),
          ],
        ),
      ],
    );
  }
}

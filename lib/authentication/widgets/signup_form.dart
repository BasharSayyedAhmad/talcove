import 'package:flutter/material.dart';
import 'package:talcove/authentication/widgets/confirm_password_field.dart';
import 'package:talcove/authentication/widgets/password_field.dart';
import 'package:talcove/core/constants/app_breakpoints.dart';
import 'package:talcove/core/constants/app_dimensions.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/shared/widgets/custom_text.dart';

class SignupForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final height = AppDimensions.screenHeight(context);
    final width = AppDimensions.screenWidth(context);
    final isMbile = width < AppBreakpoints.tablet;
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isMbile ? height * 0.1 : height * 0.2),
          Text(
            S.of(context).createYourAccount,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          CustomText(
            controller: usernameController,
            hintText: "User name",
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
            hintText: "Email(optional)",
            prefixIcon: const Icon(Icons.email),
          ),
          const SizedBox(height: 10),
          PasswordFiled(passwordController: passwordController),
          const SizedBox(height: 10),
          ConfirmPassword(
            passwordController: passwordController,
            confirmController: confirmPasswordController,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ElevatedButton(
              onPressed: () async {
                if (validateKey.currentState!.validate()) {
                  await Future.delayed(const Duration(seconds: 1));
                }
              },
              child: const Text("SignUp", style: TextStyle(fontSize: 20)),
            ),
          ),
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.discord),
                  color: Colors.deepPurple,
                ),
              ),
              Container(
                height: 50,
                width: 50,
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
            ],
          ),
        ],
      ),
    );
  }
}

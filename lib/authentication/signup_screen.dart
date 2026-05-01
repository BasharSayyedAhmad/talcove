import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/core/utils/validators.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/features/providers/theme_provider.dart';
import 'package:talcove/shared/widgets/custom_text.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();

  final confirmPasswordController = TextEditingController();
  GlobalKey<FormState> validateKey = GlobalKey<FormState>();
  String? password;
  String? confrim;
  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    return Form(
      key: validateKey,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(S.of(context).createAccount),
          actions: [
            IconButton(
              onPressed: () {
                ref.watch(themeNotifierProvider.notifier).toggleTheme();
              },
              icon: Icon(
                theme == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.15),
              Text(
                S.of(context).createYourAccount,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
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
              const PasswordFiledSignUp(),
              const SizedBox(height: 10),
              const ConfirmPasswordSignUp(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (validateKey.currentState!.validate()) {
                    await Future.delayed(const Duration(seconds: 1));
                  }
                },
                child: const Text("SignUp", style: TextStyle(fontSize: 20)),
              ),
              Row(
                children: [
                  const Expanded(child: Divider(indent: 5, thickness: 1)),
                  Text(S.of(context).orSignUpWith),
                  const Expanded(child: Divider(indent: 5, thickness: 1)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordFiledSignUp extends StatefulWidget {
  const PasswordFiledSignUp({super.key, this.password});
  final String? password;

  @override
  State<PasswordFiledSignUp> createState() => _PasswordFiledSignUpState();
}

class _PasswordFiledSignUpState extends State<PasswordFiledSignUp> {
  final passwordController = TextEditingController();

  bool isVisible = true;
  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomText(
      controller: passwordController,
      hintText: S.of(context).password,
      show: isVisible,
      validator: (val) => Validators.password(context, val),
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            isVisible = !isVisible;
          });
        },
        icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
      ),
    );
  }
}

class ConfirmPasswordSignUp extends StatefulWidget {
  const ConfirmPasswordSignUp({super.key, this.confirm, this.onChanged});
  final String? confirm;
  final String? Function(String)? onChanged;
  @override
  State<ConfirmPasswordSignUp> createState() => _ConfirmPasswordSignUpState();
}

class _ConfirmPasswordSignUpState extends State<ConfirmPasswordSignUp> {
  final confirmController = TextEditingController();
  bool isVisible = true;
  @override
  void dispose() {
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomText(
      controller: confirmController,
      hintText: S.of(context).confirm,
      onChanged: widget.onChanged,
      show: isVisible,
      prefixIcon: const Icon(Icons.password),
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            isVisible = !isVisible;
          });
        },
        icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
      ),
    );
  }
}

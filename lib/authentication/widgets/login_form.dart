import 'package:flutter/material.dart';
import 'package:talcove/authentication/widgets/password_field.dart';
import 'package:talcove/core/constants/app_breakpoints.dart';
import 'package:talcove/core/constants/app_dimensions.dart';
import 'package:talcove/shared/widgets/custom_text.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.userNameController,
    required this.passwordController,
  });
  final TextEditingController userNameController;
  final TextEditingController passwordController;
  @override
  Widget build(BuildContext context) {
    final height = AppDimensions.screenHeight(context);
    final width = AppDimensions.screenWidth(context);
    final isMobile = width < AppBreakpoints.tablet;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: isMobile ? height * 0.15 : height * 0.2),
        const Text("Login to your account", style: TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        CustomText(
          controller: userNameController,
          hintText: "User name",
          prefixIcon: const Icon(Icons.person),
          validator: (val) {
            if (val!.isEmpty) {
              return "This field can not be empty";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        PasswordFiled(passwordController: passwordController),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {},
          child: const Text("Sign in", style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: Divider(color: Colors.amber, thickness: 1, indent: 5),
            ),
            Text(" or sign in with"),
            Expanded(
              child: Divider(color: Colors.amber, thickness: 1, indent: 6),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
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
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.discord),
                color: Colors.deepPurple,
              ),
            ),

            GestureDetector(
              onTap: () {
                print("Google sign in");
              },
              child: Container(
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
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("don't have account?"),
            TextButton(onPressed: () {}, child: const Text("SignUp")),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/authentication/email_screen.dart';
import 'package:talcove/authentication/phone_screen.dart';
import 'package:talcove/authentication/widgets/signup_form.dart';
import 'package:talcove/core/constants/app_breakpoints.dart';
import 'package:talcove/core/constants/app_dimensions.dart';
import 'package:talcove/core/constants/auth_method.dart';
import 'package:talcove/features/home/home_screen.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/models/auth_state.dart';
import 'package:talcove/shared/widgets/app_snackbar.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  GlobalKey<FormState> validateKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = AppDimensions.screenWidth(context);
    final isMobile = width < AppBreakpoints.tablet;
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.errorMessage != null) {
        AppSnackBar.show(
          context,
          message: next.errorMessage!,
          backgroundColor: Colors.red,
        );
        authNotifier.clearError();
      }

      if (next.isAuthenticated && prev?.isAuthenticated != true) {
        AppSnackBar.show(
          context,
          message: S.of(context).signupSuccess,
          backgroundColor: Colors.green,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Widget nextScreen;
          if (next.authMethod == AuthMethod.google) {
            final hasPhoneNumber =
                next.user?.phoneNumber != null &&
                next.user!.phoneNumber!.isNotEmpty;
            if (hasPhoneNumber) {
              nextScreen = const HomeScreen();
            } else {
              nextScreen = const PhoneScreen();
            }
          } else {
            nextScreen = const EmailScreen();
          }
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => nextScreen),
            (route) => false,
          );
        });
      }
    });

    return Form(
      key: validateKey,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,

        body: authState.isLoading
            ? Center(
                child: Transform.scale(
                  scale: 2,
                  child: const CupertinoActivityIndicator(),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: isMobile
                      ? SignupForm(
                          usernameController: usernameController,
                          emailController: emailController,
                          passwordController: passwordController,
                          confirmPasswordController: confirmPasswordController,
                          validateKey: validateKey,
                        )
                      : Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Card(
                              margin: const EdgeInsets.all(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SignupForm(
                                  usernameController: usernameController,
                                  emailController: emailController,
                                  passwordController: passwordController,
                                  confirmPasswordController:
                                      confirmPasswordController,
                                  validateKey: validateKey,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/authentication/widgets/login_form.dart';
import 'package:talcove/core/constants/app_breakpoints.dart';
import 'package:talcove/core/constants/app_dimensions.dart';
import 'package:talcove/features/home/home_screen.dart';
import 'package:talcove/features/providers/auth_provider.dart';

import 'package:talcove/generated/l10n.dart';
import 'package:talcove/models/auth_state.dart';
import 'package:talcove/shared/widgets/app_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> validateKey = GlobalKey<FormState>();

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = AppDimensions.screenWidth(context);
    final isMobile = width < AppBreakpoints.tablet;
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage!.trim().isNotEmpty) {
        AppSnackBar.show(
          context,
          message: next.errorMessage!,
          backgroundColor: Colors.red,
        );
      }

      if (next.isAuthenticated && prev?.isAuthenticated != true) {
        AppSnackBar.show(
          context,
          message: S.of(context).signupSuccess,
          backgroundColor: Colors.green,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        });
      }
    });

    return Form(
      key: validateKey,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: authState.isLoading
              ? Center(
                  child: Transform.scale(
                    scale: 2,
                    child: CupertinoActivityIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: isMobile
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7.0),
                          child: LoginForm(
                            userNameController: userNameController,
                            passwordController: passwordController,
                            validatorKey: validateKey,
                          ),
                        )
                      : Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Card(
                              margin: const EdgeInsets.all(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: LoginForm(
                                  userNameController: userNameController,
                                  passwordController: passwordController,
                                  validatorKey: validateKey,
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

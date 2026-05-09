import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/authentication/widgets/login_form.dart';
import 'package:talcove/core/constants/app_breakpoints.dart';
import 'package:talcove/core/constants/app_dimensions.dart';
import 'package:talcove/features/home/home_screen.dart';
import 'package:talcove/features/providers/auth_provider.dart';

import 'package:talcove/features/providers/theme_provider.dart';
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
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
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

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
    return Form(
      key: validateKey,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text(S.of(context).login),

          actions: [
            IconButton(
              onPressed: () {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
              icon: Icon(
                theme == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
          ],
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: authState.isLoading
            ? Center(
                child: Transform.scale(
                  scale: 2,
                  child: const CupertinoActivityIndicator(color: Colors.orange),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(10),
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
                          child: IntrinsicHeight(
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

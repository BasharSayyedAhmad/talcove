import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/authentication/phone_screen.dart';
import 'package:talcove/core/constants/app_breakpoints.dart';
import 'package:talcove/core/constants/app_dimensions.dart';
import 'package:talcove/features/providers/auth_provider.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/models/auth_state.dart';
import 'package:talcove/shared/widgets/app_snackbar.dart';
import 'package:talcove/shared/widgets/custom_text.dart';

class EmailScreen extends ConsumerStatefulWidget {
  const EmailScreen({super.key});

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = AppDimensions.screenWidth(context);
    final isMobile = width < AppBreakpoints.tablet;
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authNotifierProvider);
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      print("=== EMAIL SCREEN DEBUG ===");
      print("next.errorMessage: ${next.errorMessage}");
      print("next.user?.email: ${next.user?.email}");
      print("emailController.text: ${emailController.text.trim()}");
      print("next.isLoading: ${next.isLoading}");
      if (next.errorMessage != null &&
          next.errorMessage != prev!.errorMessage) {
        AppSnackBar.show(context, message: next.errorMessage!);
        ref.read(authNotifierProvider.notifier).clearError();
      }

      // if (next.errorMessage == null &&
      //     next.user?.email == emailController.text.trim())
      if (!next.isLoading &&
          prev?.isLoading == true &&
          next.user?.email == emailController.text.trim()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const PhoneScreen()),
            (route) => false,
          );
        });
      }
    });
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/talcove_logo.png",
                      width: isMobile ? 120 : 140,
                      height: isMobile ? 120 : 140,
                    ),

                    const SizedBox(height: 24),

                    Text(
                      S.of(context).emailScreenTitle,
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      S.of(context).emailScreenSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  S.of(context).emailScreenBenefit1,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  S.of(context).emailScreenBenefit2,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.badge,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  S.of(context).emailScreenBenefit3,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Form(
                      key: _formKey,
                      child: CustomText(
                        controller: emailController,
                        hintText: S.of(context).emailScreenHint,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains('@') || !value.contains('.')) {
                              return "Enter a valid email address";
                            }
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    authState.isLoading
                        ? const Center(child: CupertinoActivityIndicator())
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ref
                                    .read(authNotifierProvider.notifier)
                                    .updateEmail(emailController.text.trim());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              S.of(context).emailScreenButton,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PhoneScreen(),
                          ),
                        );
                      },
                      child: Text(
                        S.of(context).emailScreenSkip,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

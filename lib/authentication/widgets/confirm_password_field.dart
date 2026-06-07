import 'package:flutter/material.dart';
import 'package:talcove/core/utils/validators.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/shared/widgets/custom_text.dart';

class ConfirmPassword extends StatefulWidget {
  const ConfirmPassword({
    super.key,
    required this.confirmController,
    required this.passwordController,
  });
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  @override
  State<ConfirmPassword> createState() => _ConfirmPasswordSignUpState();
}

class _ConfirmPasswordSignUpState extends State<ConfirmPassword> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      controller: widget.confirmController,
      hintText: S.of(context).confirm,

      validator: (val) => Validators.confrimPassword(
        context,
        val,
        widget.passwordController.text,
      ),
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

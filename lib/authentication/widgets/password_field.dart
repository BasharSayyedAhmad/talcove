import 'package:flutter/material.dart';
import 'package:talcove/core/utils/validators.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/shared/widgets/custom_text.dart';

class PasswordFiled extends StatefulWidget {
  const PasswordFiled({
    super.key,
    this.password,
    this.onChanged,
    required this.passwordController,
  });
  final String? password;
  final Function(String)? onChanged;
  final TextEditingController passwordController;

  @override
  State<PasswordFiled> createState() => _PasswordFiledSignUpState();
}

class _PasswordFiledSignUpState extends State<PasswordFiled> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      controller: widget.passwordController,
      hintText: S.of(context).password,
      onChanged: widget.onChanged,
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

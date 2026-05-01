import 'package:flutter/material.dart';
import 'package:talcove/generated/l10n.dart';

class Validators {
  static String? username(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).userNameValidatorEmpty;
    }
    return null;
  }

  static String? password(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).passwordValidatorEmpty;
    }
    if (value.length < 6) {
      return S.of(context).passwordValidatorShort;
    }
    return null;
  }

  static String? confrimPassword(
    BuildContext context,
    String? value,
    String? original,
  ) {
    if (value == null || value.isEmpty) {
      return S.of(context).confirmPasswordValidatorEmpty;
    }
    if (value != original) {
      return S.of(context).confirmPasswordNotMatch;
    }
    return null;
  }
}

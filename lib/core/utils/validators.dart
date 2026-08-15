import 'package:flutter/material.dart';
import 'package:talcove/generated/l10n.dart';

class Validators {
  static String? username(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).userNameValidatorEmpty;
    }

    return null;
  }

  static String? email(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).emailValidatorEmpty;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return S.of(context).emailValidatorInvalid;
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

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return S.of(context).passwordWeak;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return S.of(context).passwordWeak;
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return S.of(context).passwordWeak;
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

  static String? phone(
    BuildContext context,
    String? value, {
    bool isOptional = false,
  }) {
    final input = value?.trim();

    if (isOptional && (input == null || input.isEmpty)) {
      return null;
    }

    if (!isOptional && (input == null || input.isEmpty)) {
      return S.of(context).phoneValidatorEmpty;
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(input!)) {
      return S.of(context).phoneValidatorInvalid;
    }

    return null;
  }

  static bool isStrongPassword(String password) {
    if (password.length < 6) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;
    return true;
  }
}

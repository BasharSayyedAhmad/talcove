import 'package:flutter/material.dart';
import 'package:talcove/generated/l10n.dart';

class Validators {
  static String? password(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).passwordValidatorEmpty;
    }
    if (value.length < 6) {
      S.of(context).passwordValidatorShort;
    }
    return null;
  }

  static String? username(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).userNameValidatorEmpty;
    }
    return null;
  }
}

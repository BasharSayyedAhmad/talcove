// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "DontHaveAccount": MessageLookupByLibrary.simpleMessage(
      "don\'t have account",
    ),
    "UserName": MessageLookupByLibrary.simpleMessage("UserName"),
    "confirm": MessageLookupByLibrary.simpleMessage("Re-Type your password"),
    "confirmPasswordNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "confirmPasswordValidatorEmpty": MessageLookupByLibrary.simpleMessage(
      "Please confirm your password",
    ),
    "continueWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Continue with google",
    ),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create account"),
    "createYourAccount": MessageLookupByLibrary.simpleMessage(
      "Create your account",
    ),
    "email": MessageLookupByLibrary.simpleMessage("Email(optional)"),
    "login": MessageLookupByLibrary.simpleMessage("Sign in"),
    "loginToYourAccount": MessageLookupByLibrary.simpleMessage(
      "Login to your account",
    ),
    "or": MessageLookupByLibrary.simpleMessage("OR"),
    "orSignUpWith": MessageLookupByLibrary.simpleMessage("OR"),
    "orSigninWith": MessageLookupByLibrary.simpleMessage("or sign in with"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordValidatorEmpty": MessageLookupByLibrary.simpleMessage(
      "Password is required",
    ),
    "passwordValidatorShort": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "passwordWeak": MessageLookupByLibrary.simpleMessage(
      "Password is too weak. Use at least 8 characters with uppercase, lowercase, numbers, and special characters.",
    ),
    "signin": MessageLookupByLibrary.simpleMessage("Sign in"),
    "signup": MessageLookupByLibrary.simpleMessage("Sign up"),
    "signupSuccess": MessageLookupByLibrary.simpleMessage("Welcome!"),
    "userNameValidatorEmpty": MessageLookupByLibrary.simpleMessage(
      "UserName is required",
    ),
    "welcomeBack": MessageLookupByLibrary.simpleMessage("Welcome back!"),
  };
}

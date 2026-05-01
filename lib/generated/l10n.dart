// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Signup`
  String get signup {
    return Intl.message('Signup', name: 'signup', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Create account`
  String get createAccount {
    return Intl.message(
      'Create account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create your account`
  String get createYourAccount {
    return Intl.message(
      'Create your account',
      name: 'createYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `UserName`
  String get UserName {
    return Intl.message('UserName', name: 'UserName', desc: '', args: []);
  }

  /// `Email(optional)`
  String get email {
    return Intl.message('Email(optional)', name: 'email', desc: '', args: []);
  }

  /// ` or sign up with`
  String get orSignUpWith {
    return Intl.message(
      ' or sign up with',
      name: 'orSignUpWith',
      desc: '',
      args: [],
    );
  }

  /// `Re-Type your password`
  String get confirm {
    return Intl.message(
      'Re-Type your password',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Password is required`
  String get passwordValidatorEmpty {
    return Intl.message(
      'Password is required',
      name: 'passwordValidatorEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordValidatorShort {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordValidatorShort',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your password`
  String get confirmPasswordValidatorEmpty {
    return Intl.message(
      'Please confirm your password',
      name: 'confirmPasswordValidatorEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get confirmPasswordNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'confirmPasswordNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `UserName is required`
  String get userNameValidatorEmpty {
    return Intl.message(
      'UserName is required',
      name: 'userNameValidatorEmpty',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

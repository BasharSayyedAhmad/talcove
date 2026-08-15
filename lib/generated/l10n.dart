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

  /// `Sign in`
  String get login {
    return Intl.message('Sign in', name: 'login', desc: '', args: []);
  }

  /// `Sign up`
  String get signup {
    return Intl.message('Sign up', name: 'signup', desc: '', args: []);
  }

  /// `Sign in`
  String get signin {
    return Intl.message('Sign in', name: 'signin', desc: '', args: []);
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

  /// `Login to your account`
  String get loginToYourAccount {
    return Intl.message(
      'Login to your account',
      name: 'loginToYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back!`
  String get welcomeBack {
    return Intl.message(
      'Welcome back!',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `or sign in with`
  String get orSigninWith {
    return Intl.message(
      'or sign in with',
      name: 'orSigninWith',
      desc: '',
      args: [],
    );
  }

  /// `don't have account`
  String get DontHaveAccount {
    return Intl.message(
      'don\'t have account',
      name: 'DontHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Welcome!`
  String get signupSuccess {
    return Intl.message('Welcome!', name: 'signupSuccess', desc: '', args: []);
  }

  /// `UserName`
  String get UserName {
    return Intl.message('UserName', name: 'UserName', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Edit Username`
  String get editUsername {
    return Intl.message(
      'Edit Username',
      name: 'editUsername',
      desc: '',
      args: [],
    );
  }

  /// `Edit Email`
  String get editEmail {
    return Intl.message('Edit Email', name: 'editEmail', desc: '', args: []);
  }

  /// `Edit Phone Number`
  String get editPhone {
    return Intl.message(
      'Edit Phone Number',
      name: 'editPhone',
      desc: '',
      args: [],
    );
  }

  /// `Edit Bio`
  String get editBio {
    return Intl.message('Edit Bio', name: 'editBio', desc: '', args: []);
  }

  /// `Bio`
  String get bio {
    return Intl.message('Bio', name: 'bio', desc: '', args: []);
  }

  /// `No bio yet`
  String get noBio {
    return Intl.message('No bio yet', name: 'noBio', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Please enter a valid email address`
  String get invalidEmail {
    return Intl.message(
      'Please enter a valid email address',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get userName {
    return Intl.message('Username', name: 'userName', desc: '', args: []);
  }

  /// `Not provided`
  String get notProvided {
    return Intl.message(
      'Not provided',
      name: 'notProvided',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `OR`
  String get or {
    return Intl.message('OR', name: 'or', desc: '', args: []);
  }

  /// `Continue with google`
  String get continueWithGoogle {
    return Intl.message(
      'Continue with google',
      name: 'continueWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get orSignUpWith {
    return Intl.message('OR', name: 'orSignUpWith', desc: '', args: []);
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

  /// `Email is required`
  String get emailValidatorEmpty {
    return Intl.message(
      'Email is required',
      name: 'emailValidatorEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address`
  String get emailValidatorInvalid {
    return Intl.message(
      'Please enter a valid email address',
      name: 'emailValidatorInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Password is too weak. Use at least 8 characters with uppercase, lowercase, numbers, and special characters.`
  String get passwordWeak {
    return Intl.message(
      'Password is too weak. Use at least 8 characters with uppercase, lowercase, numbers, and special characters.',
      name: 'passwordWeak',
      desc: '',
      args: [],
    );
  }

  /// `Add Email Address`
  String get emailScreenTitle {
    return Intl.message(
      'Add Email Address',
      name: 'emailScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add your email to help recover your account and receive important notifications`
  String get emailScreenSubtitle {
    return Intl.message(
      'Add your email to help recover your account and receive important notifications',
      name: 'emailScreenSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `example@domain.com`
  String get emailScreenHint {
    return Intl.message(
      'example@domain.com',
      name: 'emailScreenHint',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get emailScreenButton {
    return Intl.message('Save', name: 'emailScreenButton', desc: '', args: []);
  }

  /// `Skip`
  String get emailScreenSkip {
    return Intl.message('Skip', name: 'emailScreenSkip', desc: '', args: []);
  }

  /// `📧 Password recovery`
  String get emailScreenBenefit1 {
    return Intl.message(
      '📧 Password recovery',
      name: 'emailScreenBenefit1',
      desc: '',
      args: [],
    );
  }

  /// `🔔 Account notifications`
  String get emailScreenBenefit2 {
    return Intl.message(
      '🔔 Account notifications',
      name: 'emailScreenBenefit2',
      desc: '',
      args: [],
    );
  }

  /// `🆔 Unique identifier for your account`
  String get emailScreenBenefit3 {
    return Intl.message(
      '🆔 Unique identifier for your account',
      name: 'emailScreenBenefit3',
      desc: '',
      args: [],
    );
  }

  /// `Add Phone Number`
  String get phoneScreenTitle {
    return Intl.message(
      'Add Phone Number',
      name: 'phoneScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your phone number helps others find you easily and connect with you`
  String get phoneScreenSubtitle {
    return Intl.message(
      'Your phone number helps others find you easily and connect with you',
      name: 'phoneScreenSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your phone number (e.g., +96123456789)`
  String get phoneScreenHint {
    return Intl.message(
      'Enter your phone number (e.g., +96123456789)',
      name: 'phoneScreenHint',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get phoneScreenButton {
    return Intl.message('Save', name: 'phoneScreenButton', desc: '', args: []);
  }

  /// `Skip`
  String get phoneScreenSkip {
    return Intl.message('Skip', name: 'phoneScreenSkip', desc: '', args: []);
  }

  /// `🔍 Appears in search results`
  String get phoneScreenBenefit1 {
    return Intl.message(
      '🔍 Appears in search results',
      name: 'phoneScreenBenefit1',
      desc: '',
      args: [],
    );
  }

  /// `💬 Makes it easy for friends to reach you`
  String get phoneScreenBenefit2 {
    return Intl.message(
      '💬 Makes it easy for friends to reach you',
      name: 'phoneScreenBenefit2',
      desc: '',
      args: [],
    );
  }

  /// `👥 Helps others discover you`
  String get phoneScreenBenefit3 {
    return Intl.message(
      '👥 Helps others discover you',
      name: 'phoneScreenBenefit3',
      desc: '',
      args: [],
    );
  }

  /// `Search Users`
  String get searchUsers {
    return Intl.message(
      'Search Users',
      name: 'searchUsers',
      desc: '',
      args: [],
    );
  }

  /// `Search by name, email or phone...`
  String get searchHint {
    return Intl.message(
      'Search by name, email or phone...',
      name: 'searchHint',
      desc: '',
      args: [],
    );
  }

  /// `No users found`
  String get noUsersFound {
    return Intl.message(
      'No users found',
      name: 'noUsersFound',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get message {
    return Intl.message('Message', name: 'message', desc: '', args: []);
  }

  /// `Privacy Settings`
  String get privacySettings {
    return Intl.message(
      'Privacy Settings',
      name: 'privacySettings',
      desc: '',
      args: [],
    );
  }

  /// `Show my email`
  String get showEmail {
    return Intl.message('Show my email', name: 'showEmail', desc: '', args: []);
  }

  /// `Who can see your email address`
  String get whoCanSeeEmail {
    return Intl.message(
      'Who can see your email address',
      name: 'whoCanSeeEmail',
      desc: '',
      args: [],
    );
  }

  /// `Show my phone number`
  String get showPhoneNumber {
    return Intl.message(
      'Show my phone number',
      name: 'showPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Who can see your phone number`
  String get whoCanSeePhone {
    return Intl.message(
      'Who can see your phone number',
      name: 'whoCanSeePhone',
      desc: '',
      args: [],
    );
  }

  /// `Erreur : {error}`
  String errorOccurred(Object error) {
    return Intl.message(
      'Erreur : $error',
      name: 'errorOccurred',
      desc: '',
      args: [error],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `No results found`
  String get noResultsFound {
    return Intl.message(
      'No results found',
      name: 'noResultsFound',
      desc: '',
      args: [],
    );
  }

  /// `Try a different search keyword`
  String get tryDifferentKeyword {
    return Intl.message(
      'Try a different search keyword',
      name: 'tryDifferentKeyword',
      desc: '',
      args: [],
    );
  }

  /// `Search for users`
  String get searchForUsers {
    return Intl.message(
      'Search for users',
      name: 'searchForUsers',
      desc: '',
      args: [],
    );
  }

  /// `Enter a username to search`
  String get enterUsernameToSearch {
    return Intl.message(
      'Enter a username to search',
      name: 'enterUsernameToSearch',
      desc: '',
      args: [],
    );
  }

  /// `language`
  String get language {
    return Intl.message('language', name: 'language', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Dark mode`
  String get dark {
    return Intl.message('Dark mode', name: 'dark', desc: '', args: []);
  }

  /// `Log out`
  String get logOut {
    return Intl.message('Log out', name: 'logOut', desc: '', args: []);
  }

  /// `Sign out of your account`
  String get SignOutOfYourAccount {
    return Intl.message(
      'Sign out of your account',
      name: 'SignOutOfYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `People`
  String get people {
    return Intl.message('People', name: 'people', desc: '', args: []);
  }

  /// `Chats`
  String get chats {
    return Intl.message('Chats', name: 'chats', desc: '', args: []);
  }

  /// `Groups`
  String get groups {
    return Intl.message('Groups', name: 'groups', desc: '', args: []);
  }

  /// `Search conversations...`
  String get searchConversations {
    return Intl.message(
      'Search conversations...',
      name: 'searchConversations',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `No conversations yet`
  String get noConversationsYet {
    return Intl.message(
      'No conversations yet',
      name: 'noConversationsYet',
      desc: '',
      args: [],
    );
  }

  /// `Connecting...`
  String get connecting {
    return Intl.message(
      'Connecting...',
      name: 'connecting',
      desc: '',
      args: [],
    );
  }

  /// `Start a conversation`
  String get startAConversation {
    return Intl.message(
      'Start a conversation',
      name: 'startAConversation',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get reply {
    return Intl.message('Reply', name: 'reply', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Message copied`
  String get messageCopied {
    return Intl.message(
      'Message copied',
      name: 'messageCopied',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get online {
    return Intl.message('Online', name: 'online', desc: '', args: []);
  }

  /// `No messages yet`
  String get noMessagesYet {
    return Intl.message(
      'No messages yet',
      name: 'noMessagesYet',
      desc: '',
      args: [],
    );
  }

  /// `Type a message...`
  String get typeMessage {
    return Intl.message(
      'Type a message...',
      name: 'typeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Choose your preferred language`
  String get choosePreferredLanguage {
    return Intl.message(
      'Choose your preferred language',
      name: 'choosePreferredLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Language will be changed immediately`
  String get languageChangedImmediately {
    return Intl.message(
      'Language will be changed immediately',
      name: 'languageChangedImmediately',
      desc: '',
      args: [],
    );
  }

  /// `Language changed to `
  String get languageChangedTo {
    return Intl.message(
      'Language changed to ',
      name: 'languageChangedTo',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get logoutConfirmation {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'logoutConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode on`
  String get darkModeOn {
    return Intl.message('Dark mode on', name: 'darkModeOn', desc: '', args: []);
  }

  /// `Light mode on`
  String get lightModeOn {
    return Intl.message(
      'Light mode on',
      name: 'lightModeOn',
      desc: '',
      args: [],
    );
  }

  /// `Sound, vibration, alerts`
  String get soundVibrationAlerts {
    return Intl.message(
      'Sound, vibration, alerts',
      name: 'soundVibrationAlerts',
      desc: '',
      args: [],
    );
  }

  /// `Preferences`
  String get preferences {
    return Intl.message('Preferences', name: 'preferences', desc: '', args: []);
  }

  /// `Email, phone, visibility`
  String get emailPhoneVisibility {
    return Intl.message(
      'Email, phone, visibility',
      name: 'emailPhoneVisibility',
      desc: '',
      args: [],
    );
  }

  /// `Name, photo, bio`
  String get namePhotoBio {
    return Intl.message(
      'Name, photo, bio',
      name: 'namePhotoBio',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `Edit First Name`
  String get editFirstName {
    return Intl.message(
      'Edit First Name',
      name: 'editFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Edit Last Name`
  String get editLastName {
    return Intl.message(
      'Edit Last Name',
      name: 'editLastName',
      desc: '',
      args: [],
    );
  }

  /// `First name is required`
  String get firstNameRequired {
    return Intl.message(
      'First name is required',
      name: 'firstNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Last name is required`
  String get lastNameRequired {
    return Intl.message(
      'Last name is required',
      name: 'lastNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Notification Settings`
  String get notificationsSettings {
    return Intl.message(
      'Notification Settings',
      name: 'notificationsSettings',
      desc: '',
      args: [],
    );
  }

  /// `Enable Notifications`
  String get enableNotifications {
    return Intl.message(
      'Enable Notifications',
      name: 'enableNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Receive alerts and new messages inside the app`
  String get enableNotificationsSubtitle {
    return Intl.message(
      'Receive alerts and new messages inside the app',
      name: 'enableNotificationsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your phone number`
  String get phoneValidatorEmpty {
    return Intl.message(
      'Please enter your phone number',
      name: 'phoneValidatorEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number (e.g. +1234567890)`
  String get phoneValidatorInvalid {
    return Intl.message(
      'Please enter a valid phone number (e.g. +1234567890)',
      name: 'phoneValidatorInvalid',
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

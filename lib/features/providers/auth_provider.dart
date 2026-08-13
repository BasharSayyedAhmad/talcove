import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:talcove/authentication/entry_screen.dart';
import 'package:talcove/core/constants/api_constants.dart';
import 'package:talcove/core/constants/app_settings_keys.dart';
import 'package:talcove/core/constants/auth_method.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/core/services/auth_service.dart';
import 'package:talcove/features/providers/chat_provider.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
import 'package:talcove/features/providers/ordered_contacts_provider.dart';
import 'package:talcove/models/auth_state.dart';
import 'package:talcove/models/user.dart';
import 'package:talcove/shared/services/local_storage_service.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final AuthService _authService;
  late final ApiService _apiService;
  bool _isConnectingSocket = false;

  @override
  AuthState build() {
    _authService = AuthService();
    _apiService = ApiService();
    return AuthState();
  }

  Future<String?> _getDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print("📱 Device Token: $token");
      return token;
    } catch (e) {
      print("❌ Error getting device token: $e");
      return null;
    }
  }

  Future<void> loginWithGoogle() async {
    state = AuthState(isLoading: true, errorMessage: null);

    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      String userName = googleUser.displayName?.trim() ?? '';

      if (userName.isEmpty && googleUser.email.isNotEmpty) {
        userName = googleUser.email.split('@').first;
      }

      if (idToken != null) {
        final deviceToken = await _getDeviceToken();
        final result = await _authService.loginWithGoogle(
          idToken: idToken,
          deviceToken: deviceToken,
        );

        if (result['success']) {
          final responseData = result['user'];
          final userObject = responseData['user'] ?? responseData;

          final user = User(
            id: userObject['userId'] ?? '',
            userName: userObject['userName'] ?? '',
            email: googleUser.email,
            phoneNumber: userObject['phoneNumber'] ?? '',
            photoUrl: googleUser.photoUrl,
            authType: AuthMethod.google,
          );

          await LocalStorageService.box.put(userKey, user.toJson());
          await LocalStorageService.box.put(
            authMethodKey,
            AuthMethod.google.name,
          );

          final token = _apiService.accessToken;
          if (token != null) {
            ref
                .read(messageNotifierProvider.notifier)
                .connectSocket(user.id, token);
          } else {
            print(
              "⚠️ [Socket] Token is null in ApiService during Google Login",
            );
          }

          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            user: user,
            authMethod: AuthMethod.google,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: result['error'] ?? "Login failed",
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Google authentication failed",
        );
      }
    } on PlatformException catch (e) {
      String errorMsg = "Google Sign-In failed";
      if (e.code == "network_error") {
        errorMsg = "No internet connection or Google servers unreachable";
      } else if (e.code == "12501") {
        errorMsg = "Sign-in cancelled";
      }
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
    } catch (e, stack) {
      print(e);
      print(stack);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signUpWithUserNameAndPassword(
    String userName,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final deviceToken = await _getDeviceToken();
      final result = await _authService.registerWithUsernamePassword(
        userName: userName,
        password: password,
        deviceToken: deviceToken,
      );

      if (result['success']) {
        final responseData = result['user'];
        final userObject = responseData['user'] ?? responseData;

        final user = User(
          id: userObject['userId'],
          userName: userName,
          email: userObject['email'] ?? '',
          phoneNumber: userObject['phoneNumber'] ?? '',
          photoUrl: userObject['profileImage'],
          authType: AuthMethod.userNameAndPassword,
        );

        await LocalStorageService.box.put(userKey, user.toJson());
        await LocalStorageService.box.put(
          authMethodKey,
          AuthMethod.userNameAndPassword.name,
        );

        final token = _apiService.accessToken;
        if (token != null) {
          ref
              .read(messageNotifierProvider.notifier)
              .connectSocket(user.id, token);
        }

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          authMethod: AuthMethod.userNameAndPassword,
          user: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['error'] ?? "Sign-up failed",
        );
      }
    } catch (e) {
      print(e);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loginWithUserNameAndPassword(
    String userName,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final deviceToken = await _getDeviceToken();
      final result = await _authService.loginWithUsernamePassword(
        userName: userName,
        password: password,
        deviceToken: deviceToken,
      );

      if (result['success']) {
        final responseData = result['user'];
        final accessToken = responseData['accessToken'] ?? '';
        final userObject = responseData['user'] ?? responseData;

        final user = User(
          id: userObject['userId'] ?? userName,
          userName: userName,
          email: userObject['email'] ?? '',
          phoneNumber: userObject['phoneNumber'] ?? '',
          photoUrl: userObject['profileImage'],
          authType: AuthMethod.userNameAndPassword,
        );

        await LocalStorageService.box.put(userKey, user.toJson());
        await LocalStorageService.box.put(
          authMethodKey,
          AuthMethod.userNameAndPassword.name,
        );

        ref
            .read(messageNotifierProvider.notifier)
            .connectSocket(user.id, accessToken);

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
          authMethod: AuthMethod.userNameAndPassword,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: "Invalid username or password",
        );
      }
    } catch (e) {
      print(e);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: "Try using another username or password",
      );
    }
  }

  Future<void> updateEmail(String? email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _authService.updateEmail(email);
      if (result['success']) {
        if (state.user != null) {
          final updatedUser = state.user!.copyWith(email: email);
          await LocalStorageService.box.put(userKey, updatedUser.toJson());
          state = state.copyWith(user: updatedUser);
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['error'] ?? "Failed to update email",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to update email",
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updatePhoneNumber(String? phone) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authService.updatePhoneNumber(phone);
      if (result['success']) {
        if (state.user != null) {
          final updatedUser = state.user!.copyWith(phoneNumber: phone);
          await LocalStorageService.box.put(userKey, updatedUser.toJson());
          state = state.copyWith(user: updatedUser);
        }
      }
    } catch (e) {
      print("Failed to update Phone: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> restoreSession() async {
    final box = LocalStorageService.box;
    try {
      final cookies = await _apiService.cookieJar.loadForRequest(
        Uri.parse(ApiConstants.baseUrl),
      );
      for (var cookie in cookies) {
        if (cookie.name == 'refreshToken' && cookie.expires != null) {
          final now = DateTime.now().toUtc();
          final expiry = cookie.expires!;
          print("⏰ Cookie Time left: ${expiry.difference(now).inDays} days");
        }
      }
    } catch (e) {
      print("❌ Error reading cookies: $e");
    }

    final userJson = box.get(userKey);
    final authMethod = box.get(authMethodKey);

    if (userJson == null || authMethod == null) {
      state = AuthState(isAuthenticated: false);
      return;
    }

    final user = User.fromJson(Map<String, dynamic>.from(userJson));
    state = state.copyWith(
      isAuthenticated: true,
      user: user,
      authMethod: AuthMethod.values.firstWhere(
        (e) => e.name == authMethod,
        orElse: () => AuthMethod.userNameAndPassword,
      ),
    );

    _refreshTokenInBackground();
  }

  Future<void> _refreshTokenInBackground() async {
    if (!state.hasInternet) {
      state = state.copyWith(isLoading: false);
      return;
    }
    if (_isConnectingSocket) {
      print(
        "⏳ [Socket Guard] Refresh in background ignored. Connection in progress.",
      );
      return;
    }
    state = state.copyWith(isLoading: true, hasInternet: true);

    try {
      _isConnectingSocket = true;
      final tokenRefreshed = await _authService.refreshToken();
      if (tokenRefreshed) {
        final newToken = _apiService.accessToken;
        if (newToken != null && state.user != null) {
          try {
            ref.read(messageNotifierProvider.notifier).disconnectSocket();
          } catch (e) {
            print("error while disconnecting $e");
          }
          ref
              .read(messageNotifierProvider.notifier)
              .connectSocket(state.user!.id, newToken);
        }
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        _isConnectingSocket = false;
      });
    }
  }

  void updateInternetStatus(bool hasInternet) {
    print("🌐 updateInternetStatus FIRED with: $hasInternet");
    state = state.copyWith(hasInternet: hasInternet);
    if (hasInternet && state.isAuthenticated) {
      _refreshTokenInBackground();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      state = state.copyWith(isLoading: true);

      try {
        ref.read(messageNotifierProvider.notifier).disconnectSocket();
      } catch (e) {
        print("Error disconnecting socket: $e");
      }

      if (state.authMethod == AuthMethod.google) {
        try {
          await _googleSignIn.signOut();
        } catch (e) {
          print("Google sign out error: $e");
        }
      }

      try {
        await _authService.logout();
      } catch (e) {
        print("Server logout exception: $e");
      }

      _apiService.clearAccessToken();

      try {
        await _apiService.clearAllCookies();
      } catch (e) {
        print("Error clearing cookies: $e");
      }

      try {
        await LocalStorageService.clearAll();
      } catch (e) {
        print("Error clearing local storage: $e");
      }

      ref.read(messageNotifierProvider.notifier).clearMessages();
      ref.invalidate(contactsNotifierProvider);
      ref.invalidate(orderedContactsNotifierProvider);
      ref.invalidate(messageNotifierProvider);

      state = AuthState(isAuthenticated: false, isLoading: false);

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const EntryScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      state = AuthState(isAuthenticated: false, isLoading: false);
      WidgetsBinding.instance.addPersistentFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const EntryScreen()),
            (route) => false,
          );
        }
      });
    }
  }

  Future<void> updateFirstLastName({String? fName, String? lName}) async {
    // 1. تفعيل حالة التحميل وتصفير الأخطاء السابقة
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 2. تأمين القيم: إذا مررنا قيمة جديدة نأخذها، وإلا نعتمد على القيمة الحالية بـ state لتجنب إرسال null للباك إيند
      final currentFirstName = fName ?? state.user?.firstName;
      final currentLastName = lName ?? state.user?.lastName;

      // استدعاء دالة الخدمة (ApiService) التي قمت بكتابتها
      final result = await _authService.updateFirstLastName(
        currentFirstName,
        currentLastName,
      );

      if (result['success'] == true) {
        if (state.user != null) {
          // 3. تحديث الكائن محلياً بالقيم الجديدة
          final updatedUser = state.user!.copyWith(
            firstName: currentFirstName,
            lastName: currentLastName,
          );

          // 4. حفظ البيانات المحدثة بالـ Local Storage ومزامنة الـ State
          await LocalStorageService.box.put(userKey, updatedUser.toJson());
          state = state.copyWith(user: updatedUser);

          print(
            "📝 First/Last name updated successfully: $currentFirstName $currentLastName",
          );
        }
      } else {
        // إدارة حالة الفشل من استجابة السيرفر
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['error'] ?? "Failed to update profile name",
        );
      }
    } catch (e) {
      print("Error updating first/last name: $e");
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to update profile name",
      );
    } finally {
      // إنهاء حالة التحميل دائماً بـ finally
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updatePhoto(String imagePath) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authService.updateAvatar(imagePath);

      if (result['success']) {
        if (state.user != null) {
          final updatedUser = state.user!.copyWith(
            photoUrl: result['photoUrl'],
          );
          await LocalStorageService.box.put(userKey, updatedUser.toJson());
          state = state.copyWith(user: updatedUser);
          print("📸 Avatar updated successfully: ${result['photoUrl']}");
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['error'] ?? "Failed to update avatar",
        );
      }
    } catch (e) {
      print("Error updating avatar: $e");
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to update avatar",
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> updatePrivacySettings({
    required bool emailVisible,
    required bool phoneVisible,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _authService.updatePrivacySettings(
        email: emailVisible,
        firstName: false,
        lastName: false,
        phoneNumber: phoneVisible,
        profileImage: true,
        lastSeen: true,
        userName: true,
      );

      if (result['success']) {
        if (state.user != null) {
          final updatedUser = state.user!.copyWith(
            isEmailVisible: emailVisible,
            isPhoneNumberVisible: phoneVisible,
          );
          await LocalStorageService.box.put(userKey, updatedUser.toJson());
          state = state.copyWith(user: updatedUser);
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['error'] ?? "Failed to update privacy",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to update privacy settings",
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId:
      '879638281684-c7b5ou43o5579ns0c8lbaq82p1ahja6j.apps.googleusercontent.com',
  scopes: ['email', 'profile'],
);

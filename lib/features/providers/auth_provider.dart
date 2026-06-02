import 'dart:io';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/constants/api_constants.dart';
import 'package:talcove/core/constants/app_settings_keys.dart';
import 'package:talcove/core/constants/auth_method.dart';
import 'package:talcove/core/extensions/http_extensions.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/core/services/auth_service.dart';
import 'package:talcove/features/providers/chat_provider.dart';
import 'package:talcove/models/auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talcove/models/user.dart';
import 'package:talcove/shared/services/local_storage_service.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final AuthService _authService;
  late final ApiService _apiService;

  @override
  AuthState build() {
    _authService = AuthService();
    _apiService = ApiService();
    return AuthState();
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
        final result = await _authService.loginWithGoogle(idToken);

        if (result['success']) {
          final responseData = result['user'];

          final userObject = responseData['user'] ?? responseData;
          final accessToken = responseData['accessToken'] ?? '';
          print("User object from Google: $userObject");
          print(
            "Email from Google: ${userObject['email'] ?? googleUser.email}",
          );
          print("UserName from server: ${userObject['userName']}");
          final user = User(
            id: userObject['id'] ?? userObject['userId'] ?? '',

            userName: userObject['userName'] ?? '',
            email: googleUser.email,
            phoneNumber: userObject['phoneNumber'] ?? '',
            photoUrl: googleUser.photoUrl,
            authType: AuthMethod.google,
          );

          //  تخزين بيانات المستخدم
          await LocalStorageService.box.put(userKey, user.toJson());
          await LocalStorageService.box.put(
            authMethodKey,
            AuthMethod.google.name,
          );
          ref
              .read(messageNotifierProvider.notifier)
              .connectSocket(userObject["userName"], accessToken);

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
      print("GOOGLE ERROR CODE: ${e.code}");
      print("GOOGLE ERROR MESSAGE: ${e.message}");

      if (e.code == "network_error" || e.message?.contains("7") == true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "No internet connection or Google servers unreachable",
        );
        return;
      }

      if (e.code == "12501") {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Sign-in cancelled",
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: "Google Sign-In failed",
      );
    } catch (e, stack) {
      print(e);
      print(stack);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // جلب الرسائل لاحقا من الباك
  Future<void> fetchMessages() async {
    try {
      final response = await _apiService.dio.get('/api/v1/messages');

      if (response.statusCode.isSuccess()) {
        print("Messages: ${response.data}");
      } else {
        print("Failed to fetch messages: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  Future<void> signUpWithUserNameAndPassword(
    String userName,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authService.registerWithUsernamePassword(
        userName: userName,
        password: password,
      );

      if (result['success']) {
        final responseData = result['user'];
        final userObject = responseData['user'] ?? responseData;
        print("User object: $userObject");
        print("Email from user object: ${userObject['email']}");
        print("Phone from user object: ${userObject['phoneNumber']}");

        final user = User(
          id: userObject['id'] ?? userObject['userId'] ?? userName,
          userName: userName,
          email: userObject['email'] ?? '',
          phoneNumber: userObject['phoneNumber'] ?? '',
          photoUrl: userObject['profileImage'] ?? null,
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
              .connectSocket(userName, token);
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

  // اضافة او تعديل الايميل للمستخدم
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
        print("Email updated Successfully");
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

  //اضافة رقم هاتف
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
        print("Phone number updated successfully");
      } else {
        print("Phone failed to update: ${result['error']}");
      }
    } catch (e) {
      print("Failed to update Phone: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // login
  Future<void> loginWithUserNameAndPassword(
    String userName,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authService.loginWithUsernamePassword(
        userName: userName,
        password: password,
      );

      if (result['success']) {
        // final userData = result['user'];
        // print("Full userData: ${userData['user']}");
        // print("Email from userData: ${userData['email']}");
        // print("Phone from userData: ${userData['phoneNumber']}");
        // print("All keys in userData: ${userData.keys}");
        // final user = User(
        //   id:
        //       userData['id'] ??
        //       userData['userId'] ??
        //       userData['user']['id'] ??
        //       userName,
        //   userName: userName,
        //   email: userData['email'] ?? '',
        //   photoUrl: null,
        //   authType: AuthMethod.userNameAndPassword,
        // );
        final responseData = result['user'];
        final accessToken = responseData['accessToken'] ?? '';
        final userObject = responseData['user'] ?? responseData;
        print("User object: $userObject");
        print("Response data : $responseData");
        print("Email from user object: ${userObject['email']}");
        print("Phone from user object: ${userObject['phoneNumber']}");

        final user = User(
          id: userObject['id'] ?? userObject['userId'] ?? userName,
          userName: userName,
          email: userObject['email'] ?? '',
          phoneNumber: userObject['phoneNumber'] ?? '',
          photoUrl: userObject['profileImage'] ?? null,
          authType: AuthMethod.userNameAndPassword,
        );
        await LocalStorageService.box.put(userKey, user.toJson());
        await LocalStorageService.box.put(
          authMethodKey,
          AuthMethod.userNameAndPassword.name,
        );
        ref
            .read(messageNotifierProvider.notifier)
            .connectSocket(userName, accessToken);
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
          errorMessage: result['error'] ?? "Invalid username or password",
        );
      }
    } catch (e) {
      print(e);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Future<void> restoreSession() async {
  //   final box = LocalStorageService.box;

  //   final userJson = box.get(userKey);
  //   final authMethod = box.get(authMethodKey);

  //   if (userJson == null || authMethod == null) {
  //     state = AuthState(isAuthenticated: false);
  //     return;
  //   }

  //
  //   bool hasInternet = await _checkInternetConnection();

  //   if (hasInternet) {
  //     try {
  //       final tokenRefreshed = await _authService.refreshToken();
  //       if (tokenRefreshed) {
  //         final user = User.fromJson(Map<String, dynamic>.from(userJson));
  //         state = state.copyWith(
  //           isAuthenticated: true,
  //           user: user,
  //           authMethod: AuthMethod.values.firstWhere(
  //             (e) => e.name == authMethod,
  //             orElse: () => AuthMethod.userNameAndPassword,
  //           ),
  //         );
  //         print("Session restored with fresh token");
  //         return;
  //       }
  //     } catch (e) {
  //       print("Refresh failed: $e");
  //     }
  //   }

  //   //  ثانيا: إذا ما في نت أو فشل التجديد خلي المستخدم "مسجل" بشكل مؤقت
  //   // بس مع تحذير أنه يحتاج نت للتحديث
  //   final user = User.fromJson(Map<String, dynamic>.from(userJson));
  //   state = state.copyWith(
  //     isAuthenticated: true,
  //     user: user,
  //     authMethod: AuthMethod.values.firstWhere(
  //       (e) => e.name == authMethod,
  //       orElse: () => AuthMethod.userNameAndPassword,
  //     ),
  //   );

  //   print(
  //     hasInternet
  //         ? " Using cached session (refresh failed)"
  //         : " No internet - using cached session",
  //   );
  // }

  //التحقق من الاتصال بالإنترنت
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> restoreSession() async {
    final box = LocalStorageService.box;

    try {
      final cookies = await _apiService.cookieJar.loadForRequest(
        Uri.parse(ApiConstants.baseUrl),
      );
      print("📦 Cookies found: ${cookies.length}");
      for (var cookie in cookies) {
        print("  - ${cookie.name}: expires at ${cookie.expires}");
        //  تحقق من صلاحية الـ Refresh Token
        if (cookie.name == 'refreshToken' && cookie.expires != null) {
          final now = DateTime.now().toUtc();
          final expiry = cookie.expires!;
          print("    ⏰ Time left: ${expiry.difference(now).inDays} days");
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
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      print(" No internet - using cached session");
      return;
    }

    try {
      final tokenRefreshed = await _authService.refreshToken();
      if (tokenRefreshed) {
        print(" Token refreshed in background");
        final newToken = _apiService.accessToken;
        if (newToken != null && state.user != null) {
          print("Allah akbar");
          try {
            ref.read(messageNotifierProvider.notifier).disconnectSocket();
          } catch (e) {
            print("error happened white disconnecting $e");
          }
          print(
            "🔌 Calling connectSocket with token: ${newToken.substring(0, 20)}...",
          );
          ref
              .read(messageNotifierProvider.notifier)
              .connectSocket(state.user!.userName, newToken);
        }
      } else {
        print("⚠️ Background refresh failed");

        //  إذا فشل التحديث ممكن بعدين نسجل خروج
        // ولكن نترك المستخدم في HomeScreen حالياً
        // يمكن عرض Snackbar لاحقاً او اي خرية
      }
    } catch (e) {
      print("Background refresh error: $e");
    }
  }

  // log out من سوق الجمعة لانو ليث ما عمل لسا
  Future<void> logout() async {
    if (state.authMethod == AuthMethod.google) {
      await _googleSignIn.signOut();
    }

    await _authService.logout();

    await LocalStorageService.box.delete(userKey);
    await LocalStorageService.box.delete(authMethodKey);

    state = AuthState(isAuthenticated: false);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // دالة تحديث الخصوصية
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
        profileImage: true, // افتراضي
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
        print("Privacy settings updated successfully");
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

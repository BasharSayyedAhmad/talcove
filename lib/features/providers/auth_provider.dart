import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/constants/app_settings_keys.dart';
import 'package:talcove/core/constants/auth_method.dart';
import 'package:talcove/models/auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talcove/models/user.dart';
import 'package:talcove/shared/services/local_storage_service.dart';
part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
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
        final url = Uri.parse(
          "https://chat-app-nfr1.onrender.com/api/v1/auth/google",
        );
        final body = jsonEncode({'idToken': idToken});

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        print("response body: ${response.body}");
        print("response status code: ${response.statusCode}");

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          final userJson = data['data'];
          print("=== SERVER RESPONSE ===");
          print("accessToken: ${userJson['accessToken']}");
          print("refreshToken: ${userJson['refreshToken']}");
          if (userJson['accessToken'] != null) {
            await LocalStorageService.box.put(
              accessTokenKey,
              userJson['accessToken'],
            );
          }
          if (userJson['refreshToken'] != null) {
            await LocalStorageService.box.put(
              refreshTokenKey,
              userJson['refreshToken'],
            );
          }
          final expiry = DateTime.now().add(const Duration(minutes: 30));
          await LocalStorageService.box.put(
            tokenExpiryKey,
            expiry.toIso8601String(),
          );

          final user = User(
            id: userJson['id'],
            userName:
                googleUser.displayName ?? googleUser.email.split('@').first,
            email: googleUser.email,
            photoUrl: googleUser.photoUrl,
            authType: AuthMethod.google,
          );
          await LocalStorageService.box.put(userKey, user.toJson());
          await LocalStorageService.box.put(
            authMethodKey,
            AuthMethod.google.name,
          );
          final cookies = response.headers['set-cookie'];
          print("Received cookies: $cookies");
          if (cookies != null) {
            await LocalStorageService.box.put(sessionCookieKey, cookies);
            print("Sessin cookie : $cookies");
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
            errorMessage: "Login failed: ${response.body}",
          );
        }
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
      return;
    } catch (e, stack) {
      print(e);
      print(stack);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchMessages() async {
    try {
      final box = LocalStorageService.box;
      final token = box.get(accessTokenKey);
      final cookie = box.get(sessionCookieKey);

      final response = await http.get(
        Uri.parse("https://chat-app-nfr1.onrender.com/api/v1/messages"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "Cookie": cookie ?? "",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Messages: $data");
      } else {
        print("Failed to fetch messages: ${response.body}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  Future<void> signUpWithUserNameAndPassword(
    String userName,
    String password,
    String? email,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final url = Uri.parse(
        "https://chat-app-nfr1.onrender.com/api/v1/users/register",
      );
      final body = {'userName': userName, 'password': password};
      final response = await http.post(
        url,
        body: body,
        encoding: utf8,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );
      print("response body: ${response.body}");
      print('response status : ${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final userJson = data['data'];
        print("=== SERVER RESPONSE ===");
        print("accessToken: ${userJson['accessToken']}");
        print("refreshToken: ${userJson['refreshToken']}");
        if (userJson['accessToken'] != null) {
          await LocalStorageService.box.put(
            accessTokenKey,
            userJson['accessToken'],
          );
        }

        final expiry = DateTime.now().add(const Duration(minutes: 30));
        await LocalStorageService.box.put(
          tokenExpiryKey,
          expiry.toIso8601String(),
        );
        final user = User(
          id: userJson['id'],
          userName: userName,
          email: email ?? '',
          photoUrl: null,
          authType: AuthMethod.userNameAndPassword,
        );
        await LocalStorageService.box.put(userKey, user.toJson());
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          authMethod: AuthMethod.userNameAndPassword,
        );
        await LocalStorageService.box.put(
          authMethodKey,
          AuthMethod.userNameAndPassword.name,
        );
        final cookies = response.headers['set_cookie'];
        if (cookies != null) {
          await LocalStorageService.box.put(sessionCookieKey, cookies);
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Sign-up failed: invalid username or password",
        );
      }
    } on PlatformException catch (e) {
      if (e.code == "network_error" || e.message?.contains("7") == true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "No internet connection or Google servers unreachable",
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Sign-up failed: ${e.message}",
      );
      return;
    } catch (e) {
      print(e);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loginWithUserNameAndPassword(
    String userName,
    String password,
  ) async {
    state = state.copyWith(isLoading: true);
    try {
      final url = Uri.parse(
        "https://chat-app-nfr1.onrender.com/api/v1/users/login/?userName=$userName&password=$password",
      );
      final response = await http.get(url);
      // final request = http.Request('GET', url)
      //   ..body = '{"userName": "$userName", "password": "$password"}'
      //   ..headers['Content-Type'] = 'application/json';

      // final streamedResponse = await request.send();
      // final response = await http.Response.fromStream(streamedResponse);
      print("response body: ${response.body}");
      print("status code: ${response.statusCode}");
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final userJson = data['data'];
        print("=== SERVER RESPONSE ===");
        print("accessToken: ${userJson['accessToken']}");
        print("refreshToken: ${userJson['refreshToken']}");
        if (userJson['accessToken'] != null) {
          await LocalStorageService.box.put(
            accessTokenKey,
            userJson['accessToken'],
          );
        }

        final expiry = DateTime.now().add(const Duration(minutes: 30));
        await LocalStorageService.box.put(
          tokenExpiryKey,
          expiry.toIso8601String(),
        );
        final user = User(
          id: userJson['id'],
          userName: userName,
          email: userJson['email'] ?? '',
          photoUrl: null,
          authType: AuthMethod.userNameAndPassword,
        );
        //تحديث التوكن الجديدة
        //الريفرش توكن مشان ما يضل المستخدم يسجل دخول كل نصف ساعة
        await LocalStorageService.box.put(userKey, user.toJson());
        await LocalStorageService.box.put(
          authMethodKey,
          AuthMethod.userNameAndPassword.name,
        );
        final cookies = response.headers['set_cookie'];
        if (cookies != null) {
          await LocalStorageService.box.put(sessionCookieKey, cookies);
        }
        state = state.copyWith(isAuthenticated: true, isLoading: false);
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: "Sign in failed Invalid user name or password",
        );
      }
    } on PlatformException catch (e) {
      if (e.code == "network_error" || e.message?.contains("7") == true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "No internet connection or Google servers unreachable",
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Sign in failed: ${e.message}",
      );
      return;
    } catch (e) {
      print(e);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> _refreshTokens() async {
    try {
      final accessToken = LocalStorageService.box.get(accessTokenKey);
      if (accessToken == null) return false;

      final response = await http.post(
        Uri.parse("https://chat-app-nfr1.onrender.com/api/v1/users/refresh"),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'accessToken': accessToken},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];

        // حفظ التوكن الجديدة
        await LocalStorageService.box.put(accessTokenKey, newAccessToken);

        // تحديث وقت الانتهاء
        final newExpiry = DateTime.now().add(const Duration(minutes: 30));
        await LocalStorageService.box.put(
          tokenExpiryKey,
          newExpiry.toIso8601String(),
        );
        print("Token refreshed");
        return true;
      }
      print("Refresh failed : ${response.statusCode}");
      return false;
    } catch (e) {
      print("Refresh failed: $e");
      return false;
    }
  }

  Future<bool> _isTokenExpiringSoon() async {
    final expiryStr = LocalStorageService.box.get(tokenExpiryKey);
    if (expiryStr == null) return true;

    final expiry = DateTime.parse(expiryStr);
    final timeLeft = expiry.difference(DateTime.now());

    // إذا باقي أقل من 5 دقائق جددا
    return timeLeft.inMinutes < 5;
  }

  Future<String?> _getValidAccessToken() async {
    // إذا التوكن قربت تنتهي، جددا
    if (await _isTokenExpiringSoon()) {
      final refreshed = await _refreshTokens();
      if (!refreshed) return null;
    }

    return LocalStorageService.box.get(accessTokenKey);
  }

  Future<void> restoreSession() async {
    final box = LocalStorageService.box;
    final method = box.get(authMethodKey);
    final userJson = box.get(userKey);

    print("=== RESTORE SESSION ===");
    print("Auth method: $method");
    print("User data exists: ${userJson != null}");

    if (userJson == null) {
      state = AuthState(isAuthenticated: false);
      return;
    }

    // حسب طريقة التسجيل جار
    if (method == AuthMethod.google.name) {
      // Google: يعتمد على token + cookie
      final token = box.get(accessTokenKey);
      final cookie = box.get(sessionCookieKey);
      print("=== GOOGLE RESTORE DEBUG ===");
      print("Token exists: ${token != null}");
      print("Token value: ${token?.substring(0, 30)}...");
      print("Cookie exists: ${cookie != null}");
      print("Cookie value: ${cookie?.substring(0, 50)}...");

      if (token != null && cookie != null) {
        print(
          "❌ Missing data: token=${token != null}, cookie=${cookie != null}",
        );
        await _restoreUser(
          Map<String, dynamic>.from(userJson),
          AuthMethod.google,
        );
      } else {
        state = AuthState(isAuthenticated: false);
      }
    } else if (method == AuthMethod.userNameAndPassword.name) {
      // Username/Password: يعتمد فقط على token
      final token = box.get(accessTokenKey);
      print("Username/Password - Token: ${token != null}");

      if (token != null) {
        //  تحقق من صلاحية التوكن
        if (await _isTokenExpiringSoon()) {
          final refreshed = await _refreshTokens();
          if (!refreshed) {
            state = AuthState(isAuthenticated: false);
            return;
          }
        }
        await _restoreUser(
          Map<String, dynamic>.from(userJson),
          AuthMethod.userNameAndPassword,
        );
      } else {
        state = AuthState(isAuthenticated: false);
      }
    } else {
      state = AuthState(isAuthenticated: false);
    }
  }

  // دالة مساعدة لاستعادة المستخدم
  Future<void> _restoreUser(
    Map<String, dynamic> userJson,
    AuthMethod method,
  ) async {
    final user = User.fromJson(userJson);
    state = state.copyWith(
      isAuthenticated: true,
      authMethod: method,
      user: user,
    );
  }

  Future<void> logout() async {
    final box = LocalStorageService.box;
    if (state.authMethod == AuthMethod.google) {
      await _googleSignIn.signOut();
    }
    await box.delete(accessTokenKey);
    await box.delete(sessionCookieKey);
    await box.delete(refreshTokenKey);
    await box.delete(tokenExpiryKey);
    await box.delete(userKey);
    await box.delete(authMethodKey);

    state = AuthState(isAuthenticated: false);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  // serverClientId is the "Web Client ID" from Google Cloud Console
  serverClientId:
      '879638281684-c7b5ou43o5579ns0c8lbaq82p1ahja6j.apps.googleusercontent.com',
  scopes: ['email', 'profile'],
);

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
          if (userJson['accessToken'] != null) {
            await LocalStorageService.box.put(
              accessTokenKey,
              userJson['accessToken'],
            );
          }

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
        // هون تعمل parse للـ messages وتحطها بالـ state أو model
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
      final body = jsonEncode({
        'userName': userName,
        'password': password,
        if (email != null) 'email': email,
      });
      final response = await http.post(
        url,
        body: body,
        headers: {"Content-Type": "application/json"},
      );
      print("response body: ${response.body}");
      print('response status : ${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          authMethod: AuthMethod.userNameAndPassword,
        );
        await LocalStorageService.box.put(
          authMethodKey,
          AuthMethod.userNameAndPassword.name,
        );
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
        "https://chat-app-nfr1.onrender.com/api/v1/users/login",
      ).replace(queryParameters: {'userName': userName, 'password': password});
      final response = await http.get(url);
      print("response body: ${response.body}");
      print("status code: ${response.statusCode}");
      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = state.copyWith(isAuthenticated: true, isLoading: false);
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: "Sign in failed ${response.body}",
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
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> restoreSession() async {
    final box = LocalStorageService.box;
    final token = box.get(accessTokenKey);
    final cookie = box.get(sessionCookieKey);
    final method = box.get(authMethodKey);
    final userJson = box.get(userKey);
    if (token != null && cookie != null) {
      AuthMethod authMethod;
      if (method == AuthMethod.google.name) {
        authMethod = AuthMethod.google;
      } else if (method == AuthMethod.userNameAndPassword.name) {
        authMethod = AuthMethod.userNameAndPassword;
      } else {
        authMethod = AuthMethod.google;
      }
      User? user;
      if (userJson != null) {
        user = User.fromJson(Map<String, dynamic>.from(userJson));
      }
      state = state.copyWith(
        isAuthenticated: true,
        authMethod: authMethod,
        user: user,
      );
    }
  }

  Future<void> logout() async {
    final box = LocalStorageService.box;
    if (state.authMethod == AuthMethod.google) {
      await _googleSignIn.signOut();
    }
    await box.delete(accessTokenKey);
    await box.delete(sessionCookieKey);
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

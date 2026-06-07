import 'dart:convert'; // 🔥 إضافة مكتبة الـ convert لتحويل الـ JSON
import 'dart:io';
import 'package:http/http.dart' as http; // 🔥 إضافة مكتبة الـ http لإرسال الطلب
import 'package:firebase_messaging/firebase_messaging.dart'; // 🔥 إضافة الفايربيز ميساجينج لتوليد توكن الجهاز
import 'package:googleapis_auth/auth_io.dart' as auth; // 🔥 مكتبة جوجل للتوثيق

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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

  // 🔥 دالة سرية داخلية لتوليد الـ OAuth Token الخاص بالـ FCM v1 ديناميكياً
  Future<String?> _getFirebaseServerToken() async {
    try {
      final serviceAccountJson = {
        "type": "service_account",
        "project_id": "talcove-df32e",
        "private_key_id": "b4b612d08fbd48d646fee7873daae89696b1e405",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDOfbEoMu5u0Hqt\n0n5RcTHq1/zWF0Gy0q8S9LAncA4Y55jTrjMuM8VUFvfBXnfJCp4MCNEjUnpdfsVv\nSj0GfWUGmSQXuAkY8rGWIZicw2ol7ZCC0ptacG14ZvGvtQxgyKN9LuFNT7sdRyXs\nUYHf3h6itq6TCV1c4BSJlgmrpaJ18iq4py0MNgGOxHEgCb5rmsG03pJcIvuQc+Gs\nNaeITbbdwHLnydBqkLv05QnSVrjW1JmQ/IxDNmND+LWkgED+pQCrIJ6A0PqQWHXV\nvT40JTXlLaKiXNLDxLGAUWnkYUfWgOB++1lhaUeRzoEtBoIg/bUn/mBRqRqyQF/E\nNIrYYEMrAgMBAAECggEAI2GjIOW1ODStyKn4LgFM0dYngxGiFr+F8yQNKPzI1Zid\ndav0JhcF2VZEJpSGxuJ0WVCLcVd5ExsdPmgEk9+Zl2tXJV9J48X2Cuj/yuCrCAuw\nRtJKf1EjWM2e3QITOGQ4q0MEpOgkAizGQTtoGxFmw2+08wnYPwlAS6DzUD+F2lqQ\n+QjbNAHLYU4xMn2cc1EV93DjE2+INLinK5FCVLB+QW0H6SzVReUbuj3n+mCEiGbj\niI8A6k7v/SgeO90oTklTArrhmmKIyz3EuaE9PtB+dCVcsk2muKwdwcl89aJMc7gC\n5a4g9UB1VZkeRgPjEba/DucLkTprTw6MYL/dqpLFYQKBgQDxFLgQu3WaczGvKP+S\njq9TslmjhWfZx84H4Xt/EGCfK2eFSJxp3AVNkoSGeMhu3rEOq9KpWhl3pirAMeFy\nnsNz1TaM5nrxSre6qzLD47XuBhVosCArhs+yd6kPGCueZQ1kSmEacLzrPtC+YdfH\nZZENfF4psBDLe6f96+ckLcHHoQKBgQDbRPzufxNIwEfYqq9q3UiYUhWgMV6p6S66\nHD1kUssu4hbgmZYkn1ZhKla0j/MlNfdi1JnGbg6+xbswF/tHWT5/n5pLS9ewzTNl\noj/R9NeGmDA/Js99Isomk9zOIBvDLkHr8OrXgy5El1OeIgZAUiD8NcYdQHfeSdPu\nAY89sKlnSwKBgAVznH30X0Jw3GzDlpPv2hMgc1p5R9Hq7MPM24gSDL1Ms/iVncPf\nD9ejOo/350BqlMJqLEdcHDtSbKEP/7Mh1/WkmqkxBRKzx9fWyz0WxyRsysslQHT7\nhXLZtd77gvEAA/+ClxOL/Rmsv/euKrz9lPwjFdYHfzm6wB/D1+Q/jKRBAoGBAMz3\najBPHWmuQ/rnYt7UR14LrSd3vvO5g/J5H3I+aqxCr/v31gAZ6hceCrryrOklz0DV\nV4HDs4jlMRu97yg85k1KlmK4XMFqsBbbWikbZLTuYntF/kMNWEZDhe4w2YLUJM82\n/2/BsmhvxLxXNdy+aRMZ+T2y29owzSj40Dtsfo6NAoGBAJUwqxIn6IqdDXnhraJ8\nxIFsrejEO6xf1Iw66Y+01OLnW2GS2+WI67g9/3nnY796SXKvIsWuxZOmLaQovyek\nIo0j+v+KsOvVIrLzAChoravMKIRqxU8dRaIWCls3GsGawe5yvsTQGNxXSdpyVj+k\niJIFEItK8nKFN9g9m+UIHA60\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@talcove-df32e.iam.gserviceaccount.com",
        "client_id": "102923172473316018447",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40talcove-df32e.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      };

      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final credentials = auth.ServiceAccountCredentials.fromJson(
        serviceAccountJson,
      );
      final client = await auth.clientViaServiceAccount(credentials, scopes);

      final String token = client.credentials.accessToken.data;
      client.close();
      return token;
    } catch (e) {
      print("❌ Error generating FCM Server Token: $e");
      return null;
    }
  }

  // 🔥 دالة إرسال الإشعار التجريبي بعد تحديث التوكن الموثق
  Future<void> sendTestNotification() async {
    print("⏳ Starting FCM Test Notification process...");
    final String? firebaseServerToken = await _getFirebaseServerToken();

    if (firebaseServerToken == null) {
      print("❌ Cannot send notification: Server Token is NULL");
      return;
    }

    final String? deviceToken = await FirebaseMessaging.instance.getToken();
    if (deviceToken == null) {
      print("❌ Cannot send notification: Device Token is NULL");
      return;
    }

    var headersList = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $firebaseServerToken',
    };

    var url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/talcove-df32e/messages:send',
    );

    var body = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": "Talcove Notification",
          "body": "كسم الاشعارات",
        },
        "android": {
          "priority": "HIGH",
          "notification": {
            "channel_id": "chat_notifications_channel",
            "sound": "default",
            "notification_priority": "PRIORITY_HIGH",
            "visibility": "PUBLIC",
          },
        },
        "apns": {
          "payload": {
            "aps": {"mutable-content": 1, "sound": "default", "badge": 1},
          },
        },
      },
    };

    try {
      var response = await http.post(
        url,
        headers: headersList,
        body: json.encode(body),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(
          "✅ FCM Notification Sent Successfully! Response: ${response.body}",
        );
      } else {
        print("❌ FCM Notification Failed Status: ${response.statusCode}");
        print("⚠️ Firebase Error Details: ${response.body}");
      }
    } catch (e) {
      print("❌ HTTP Request Error sending FCM: $e");
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
        final result = await _authService.loginWithGoogle(idToken);

        if (result['success']) {
          final responseData = result['user'];
          final userObject = responseData['user'] ?? responseData;
          final accessToken = responseData['accessToken'] ?? '';

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
          ref
              .read(messageNotifierProvider.notifier)
              .connectSocket(user.id, accessToken);

          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            user: user,
            authMethod: AuthMethod.google,
          );

          // 🔥 تشغيل الإشعار التجريبي فور نجاح دخول جوجل
          await sendTestNotification();
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

        // 🔥 تم نقل استدعاء الإشعار إلى هنا ليشتغل عند النجاح وليس عند الفشل!
        await sendTestNotification();
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
      final result = await _authService.loginWithUsernamePassword(
        userName: userName,
        password: password,
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

        // 🔥 تشغيل الإشعار التجريبي فور نجاح تسجيل الدخول العادي
        await sendTestNotification();
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
      for (var cookie in cookies) {
        if (cookie.name == 'refreshToken' && cookie.expires != null) {
          final now = DateTime.now().toUtc();
          final expiry = cookie.expires!;
          print(
            "    ⏰ Cookie Time left: ${expiry.difference(now).inDays} days",
          );
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
    state = state.copyWith(isLoading: true, hasInternet: true);

    try {
      final tokenRefreshed = await _authService.refreshToken();
      if (tokenRefreshed) {
        final newToken = _apiService.accessToken;
        if (newToken != null && state.user != null) {
          try {
            ref.read(messageNotifierProvider.notifier).disconnectSocket();
          } catch (e) {
            print("error white disconnecting $e");
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
    }
  }

  void updateInternetStatus(bool hasInternet) {
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
          print("⚠️ Google sign out error: $e");
        }
      }

      try {
        await _authService.logout();
      } catch (e) {
        print("⚠️ Server logout exception: $e");
      }

      _apiService.clearAccessToken();

      try {
        await _apiService.clearAllCookies();
      } catch (e) {
        print(" Error clearing cookies: $e");
      }

      try {
        await LocalStorageService.box.delete(userKey);
        await LocalStorageService.box.delete(authMethodKey);
      } catch (e) {
        print(" Error clearing local storage: $e");
      }

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
          print(" Avatar updated successfully: ${result['photoUrl']}");
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['error'] ?? "Failed to update avatar",
        );
      }
    } catch (e) {
      print(" Error updating avatar: $e");
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

// 1. أضف هذا الاستيراد في أعلى الملف تماماً مع الاستيرادات الأخرى
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http show Request;

// ... داخل كلاس AuthNotifier ...

// 🔥 دالة لتوليد توكن OAuth 2.0 من ملف الـ Service Account الذي أرسلته
Future<String?> _getFirebaseServerToken() async {
  try {
    // نضع الـ JSON الخاص بك هنا داخل الخريطة (Map)
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "talcove-df32e",
      "private_key_id": "b4b612d08fbd48d646fee7873daae89696b1e405",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDOfbEoMu5u0Hqt\n0n5RcTHq1/zWF0Gy0q8S9LAncA4Y55jTrjMuM8VUFvfBXnfJCp4MCNEjUnpdfsVv\nSj0GfWUGmSQXuAkY8rGWIZicw2ol7ZCC0ptacG14ZvGvtQxgyKN9LuFNT7sdRyXs\nUYHf3h6itq6TCV1c4BSJlgmrpaJ18iq4py0MNgGOxHEgCb5rmsG03pJcIvuQc+Gs\nNaeITbbdwHLnydBqkLv05QnSVrjW1JmQ/IxDNmND+LWkgED+pQCrIJ6A0PqQWHXV\nvT40JTXlLaKiXNLDxLGAUWnkYUfWgOB++1lhaUeRzoEtBoIg/bUn/mBRqRqyQF/E\nNIrYYEMrAgMBAAECggEAI2GjIOW1ODStyKn4LgFM0dYngxGiFr+F8yQNKPzI1Zid\ndav0JhcF2VZEJpSGxuJ0WVCLcVd5ExsdPmgEk9+Zl2tXJV9J48X2Cuj/yuCrCAuw\nRtJKf1EjWM2e3QITOGQ4q0MEpOgkAizGQTtoGxFmw2+08wnYPwlAS6DzUD+F2lqQ\n+QjbNAHLYU4xMn2cc1EV93DjE2+INLinK5FCVLB+QW0H6SzVReUbuj3n+mCEiGbj\niI8A6k7v/SgeO90oTklTArrhmmKIyz3EuaE9PtB+dCVcsk2muKwdwcl89aJMc7gC\n5a4g9UB1VZkeRgPjEba/DucLkTprTw6MYL/dqpLFYQKBgQDxFLgQu3WaczGvKP+S\njq9TslmjhWfZx84H4Xt/EGCfK2eFSJxp3AVNkoSGeMhu3rEOq9KpWhl3pirAMeFy\nsnNz1TaM5nrxSre6qzLD47XuBhVosCArhs+yd6kPGCueZQ1kSmEacLzrPtC+YdfH\nZZENfF4psBDLe6f96+ckLcHHoQKBgQDbRPzufxNIwEfYqq9q3UiYUhWgMV6p6S66\nH1kUssu4hbgmZYkn1ZhKla0j/MlNfdi1JnGbg6+xbswF/tHWT5/n5pLS9ewzTNl\noj/R9NeGmDA/Js99Isomk9zOIBvDLkHr8OrXgy5El1OeIgZAUiD8NcYdQHfeSdPu\nAY89sKlnSwKBgAVznH30X0Jw3GzDlpPv2hMgc1p5R9Hq7MPM24gSDL1Ms/iVncPf\nD9ejOo/350BqlMJqLEdcHDtSbKEP/7Mh1/WkmqkxBRKzx9fWyz0WxyRsysslQHT7\nhXLZtd77gvEAA/+ClxOL/Rmsv/euKrz9lPwjFdYHfzm6wB/D1+Q/jKRBAoGBAMz3\najBPHWmuQ/rnYt7UR14LrSd3vvO5g/J5H3I+aqxCr/v31gAZ6hceCrryrOklz0DV\nV4HDs4jlMRu97yg85k1KlmK4XMFqsBbbWikbZLTuYntF/kMNWEZDhe4w2YLUJM82\n/2/BsmhvxLxXNdy+aRMZ+T2y29owzSj40Dtsfo6NAoGBAJUwqxIn6IqdDXnhraJ8\nxIFsrejEO6xf1Iw66Y+01OLnW2GS2+WI67g9/3nnY796SXKvIsWuxZOmLaQovyek\nIo0j+v+KsOvVIrLzAChoravMKIRqxU8dRaIWCls3GsGawe5yvsTQGNxXSdpyVj+k\niJIFEItK8nKFN9g9m+UIHA60\n-----END PRIVATE KEY-----\n",
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

    // تحديد نطاق الوصول لـ Firebase Messaging
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    // توليد العميل والتوكن الموثق من جوجل
    final credentials = auth.ServiceAccountCredentials.fromJson(
      serviceAccountJson,
    );
    final client = await auth.clientViaServiceAccount(credentials, scopes);

    final String token = client.credentials.accessToken.data;
    client.close(); // إغلاق العميل بعد جلب التوكن لحفظ الموارد
    return token;
  } catch (e) {
    print("❌ خطأ أثناء توليد توكن FCM Server: $e");
    return null;
  }
}

// 2. تحديث جزء الإشعارات داخل دالة signUpWithUserNameAndPassword
// استبدل كود إرسال الإشعار القديم بهذا الكود المحدث والمحمي بـ await:
Future<void> sendTestNotification() async {
  // جلب توكن الفايربيز المولد ديناميكياً من الدالة السابقة
  final String? firebaseServerToken = await _getFirebaseServerToken();

  if (firebaseServerToken == null) {
    print("❌ تعذر إرسال الإشعار لأن توكن السيرفر فارغ");
    return;
  }

  var headersList = {
    'Accept': '*/*',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $firebaseServerToken', // تمرير التوكن الصحيح هنا
  };

  var url = Uri.parse(
    'https://fcm.googleapis.com/v1/projects/talcove-df32e/messages:send',
  );

  var body = {
    "message": {
      "token": await FirebaseMessaging.instance.getToken(),
      "notification": {"title": "hello message", "body": "welcome to our app"},
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
    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print("✅ نجح الإرسال الفوري واستلم سيرفر الفايربيز الطلب: $resBody");
    } else {
      print("❌ فشل إرسال الإشعار: ${res.reasonPhrase}");
      print("⚠️ تفاصيل الخطأ من الفايربيز: $resBody");
    }
  } catch (e) {
    print("❌ خطأ أثناء طلب الـ HTTP للإشعار: $e");
  }
}

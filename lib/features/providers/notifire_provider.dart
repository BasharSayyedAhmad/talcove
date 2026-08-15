import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http show Request;

// 🔥 1. دالة لتوليد توكن OAuth 2.0 من ملف الـ Service Account
Future<String?> _getFirebaseServerToken() async {
  try {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "talcove-df32e",
      "private_key_id": "d1e3dc3c684b19a051a51f2c4b1818f3fdcea65f",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDTdrCvWhHP+N4B\nqPTQ75BCLcJ/KBdYKf52FiWqVh8ygjjLK0HbJlia3fSP1GQepNxGuzS90MZraxmf\nlZ7KHMgxoexr4TaTM2RVKbTwklIBb2OhirMazXulMbRAAY3GQAvXUi1wu2OQkj79\nZWFEv/gOBN4ZmN8CnzJsh6+N98y3JHKvUzCWtJaKQw9X4mOR7rm7FPXtbWISEqu2\n/jjMw6/Zm/V172ibbME9o4KF149996q9WBQgfvDPGLzdhj7MGPq+Kdn69MYddNT2\n1NSIHnWYVnIij1/Ph55qF6GjhCswbrbaX1kN/Sp59NSf2XMJRldLYVZ+LA+O9ywn\nNJ6xpASLAgMBAAECggEAP+A/8dAGxmg6A41aWkyrKlpxQIDHQHH69Aevm/sE1HiC\nmFh6Pa0hIbK/H707+we4pEMDZP0OGr+Qz2ReQVYdYOS1Kkcu+ZsSCSmehvbj/5v6\nn/7qKEP+wAE6HgV6InMRQJsJr95i7nZGwbtgfOhyESYGQvwrDTsye5cm//7k30L9\nxUBZIn/T3EXWWYLfceO+A3+P3Omf71ulnDXQxaPNbuqiIwl0S8el/IFYT93fGcHQ\nNaZgCzkBDq9llN3/avef/ohKNkN000mteqiKUslT2oQEfFjkaEDzrNAcmITPuLcS\nknm2m4zHqqagb7wyYsmtDTI96iAp3/qdkfxFPVl7iQKBgQD7kQu0c9TWEFigWLgg\nAzAv8Q7kam7/WJP10reyaQKQEuNCyV0TBmg1LNeafgK5kAiljRCQU2TKQC2shx62\nVfK4ba6UTGGcghsz+PeBWEmlmRYeIa/ob7nNPlvc5NBTCuIjZ98R5WWoApFOOksd\nqHFy6nENDmsJ6oGK8uWQ4lTBcwKBgQDXMLfXp6zkzmOET1gvO3MXFuNWArZsYnvY\nuYme5UUIIMawcPMLl06v2GXJvfoNnHPxxA3K0E1WLs4Kum+FZa43N5CvCOml1LVF\ngmMaNMGbdu2hc890JwKjFEqREZNjsOVhPwrqlZ6S7d01w30/0/XtitbwhU2vbqUU\n3PHzO94KiQKBgDFyt0xHIGTbXbBXAAo61jP2PCklyp+id6LwQm9tOLW9ILK2BfeB\nYOZi5BZYAo0bBLgV3FWiLsOajd/Fx4Grr0QVOyWnReCPqm0y2OOxyPgl+TT/Bia4\nH1t6kHABAfnwv7aZ6j0ITE0UBB/OUYmI3JPsBUC9vsh6MfBwAjPSaTqFAoGBAMEL\nC2GDIi8Al3YSV+HHSy/jcH2wYUZJ8yAxEaxhsNPh01xldyNm0UgesPGSY8fiGoFA\nh77xru8pfd1R8smQtgEC7+CV9kS11QhON+lCeoyk2/iClBB3Dn6NrXcGdVpxTtU2\nYOyg3Giiyld4z9t6opw+eSO78jz23VEiBEtX4ZFBAoGBAJp56TqU/c6URErY7LWC\nYr/kuExM1ug4i1d7CUtb8jYgfw4Q8UEUdPyea0v8rShyTN/sjR7oV1i96tGbtX6w\nJIohz0K3R8/GafRxHQxKCeJBghz0rKJVkqm9Mx/+U/dDKbnkc8q4igXf46pBje7h\nS7nxXq+HwRh9fPmLYJs1J1a9\n-----END PRIVATE KEY-----\n",
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
    print("❌ خطأ أثناء توليد توكن FCM Server: $e");
    return null;
  }
}

// 🔥 2. دالة إرسال الإشعار الديناميكية لأي مستخدم آخر
Future<void> sendNotificationToUser({
  required String receiverFcmToken, // توكن الجهاز المستقبل
  required String title, // عنوان الإشعار (مثلاً: اسم المرسل)
  required String body, // نص الرسالة
  String? chatRoomId, // معرف غرفة المحادثة
  Map<String, dynamic>? data, // 👈 التعديل: إمكانية تمرير بيانات إضافية للتوجيه
}) async {
  final String? firebaseServerToken = await _getFirebaseServerToken();

  if (firebaseServerToken == null) {
    print("❌ تعذر إرسال الإشعار لأن توكن السيرفر فارغ");
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

  // دمج كافة البيانات الممررة في حقل data للـ FCM payload (تحويل كل القيم إلى String لضمان توافق FCM)
  final Map<String, String> payloadData = {
    "chat_room_id": chatRoomId ?? "",
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
  };

  if (data != null) {
    data.forEach((key, value) {
      payloadData[key] = value.toString();
    });
  }

  var messagePayload = {
    "message": {
      "token": receiverFcmToken,
      "notification": {"title": title, "body": body},
      "data": payloadData, // 🎯 البيانات المرسلة داخل الإشعار
      "android": {
        "priority": "HIGH",
        "notification": {
          "channel_id": "high_importance_channel",
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
    req.body = json.encode(messagePayload);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print("✅ تم إرسال الإشعار للمستقبل بنجاح: $resBody");
    } else {
      print("❌ فشل إرسال الإشعار: ${res.reasonPhrase}");
      print("⚠️ تفاصيل الخطأ من الفايربيز: $resBody");
    }
  } catch (e) {
    print("❌ خطأ أثناء طلب الـ HTTP للإشعار: $e");
  }
}

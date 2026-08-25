import 'dart:convert';
import 'package:http/http.dart' as http show Request;
import 'package:talcove/core/constants/firebase_secrets.dart';

Future<void> sendNotificationToUser({
  required String receiverFcmToken,
  required String title,
  required String body,
  String? chatRoomId,
  Map<String, dynamic>? data,
}) async {
  final String? firebaseServerToken = await getFirebaseServerToken();

  if (firebaseServerToken == null) {
    print(" تعذر إرسال الإشعار لأن توكن السيرفر فارغ");
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
      "data": payloadData,
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
      print(" تم إرسال الإشعار للمستقبل بنجاح: $resBody");
    } else {
      print(" فشل إرسال الإشعار: ${res.reasonPhrase}");
      print(" تفاصيل الخطأ من الفايربيز: $resBody");
    }
  } catch (e) {
    print(" خطأ أثناء طلب الـ HTTP للإشعار: $e");
  }
}

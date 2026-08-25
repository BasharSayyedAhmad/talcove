import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:talcove/core/constants/firebase_secrets.dart';

Future<void> sendTestNotification() async {
  print(" Starting FCM Test Notification process...");
  final String? firebaseServerToken = await getFirebaseServerToken();

  if (firebaseServerToken == null) {
    print(" Cannot send notification: Server Token is NULL");
    return;
  }

  final String? deviceToken = await FirebaseMessaging.instance.getToken();
  if (deviceToken == null) {
    print(" Cannot send notification: Device Token is NULL");
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
      "notification": {"title": "Talcove Notification", "body": "اشعار ترحيبي"},
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
      print(" FCM Notification Sent Successfully! Response: ${response.body}");
    } else {
      print(" FCM Notification Failed Status: ${response.statusCode}");
      print(" Firebase Error Details: ${response.body}");
    }
  } catch (e) {
    print(" HTTP Request Error sending FCM: $e");
  }
}

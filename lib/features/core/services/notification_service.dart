import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:log/log.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/constants/secrets/firebase_cloud_messaging_secrets.dart';
import 'package:rating/features/core/models/app_user.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService();
  static NotificationService get instance => _instance;

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  void init() {
    initCloudNotifications();
  }

  void initCloudNotifications() async {
    await _requestPermissions();
    await _initWeb();
    _initForegroundNotifications();
    _initBackgroundNotifications();
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    Log.hint("Notification permission granted: ${settings.authorizationStatus}");
  }

  Future<void> _initWeb() async {
    if (!kIsWeb) return;
    Log.hint("Trying to register notification token...");
    String? token = await firebaseMessaging.getToken(
      vapidKey: FirebaseCloudMessagingSecrets.webVapidKey,
    );
    Log.hint("Registrated notification token: $token");
  }

  void _initForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Log.hint("Got a message whilst in the foreground! \n\tMessage data: ${message.data}");
      if (message.notification != null) {
        Log.hint("Message also contained a notification: \n\t${message.notification?.body}");
      }
      if (notificationSendByCurrentUser(message)) return;
      final String title = message.notification?.title ?? "";
      final String content = message.notification?.body ?? "";
      showDialog(
        context: Global.context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("Okay"),
            ),
          ],
        ),
      );
    });
  }

  void _initBackgroundNotifications() {
    // ? Ignore, if notification came from current user ?
    // FirebaseMessaging.onBackgroundMessage((message) async {
    //   if (notificationSendByCurrentUser(message)) return;
    //   await _firebaseMessagingBackgroundHandler(message);
    // });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void subscribeToTopic(String topic) async {
    await firebaseMessaging.subscribeToTopic(topic);
    Log.hint("NOTIFICATIONS: Subscribed to $topic");
  }

  void unsubscribeFromTopic(String topic) async {
    await firebaseMessaging.unsubscribeFromTopic(topic);
    Log.hint("NOTIFICATIONS: Unsubscribed from $topic");
  }

  Future<bool> sendNotificationToTopic({required String topic, String? title, String? message, String? priority}) async {
    final String notificationTitle = title ?? "Neue Nachricht";
    final String notificationMessage = message ?? "Ohne Inhalt.";
    final String notificationPriority = priority == 'high' ? 'high' : 'normal';
    final data = {
      'click action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'message': notificationMessage,
      'sendBy': AppUser.current?.id ?? "no user",
      'topic': topic,
    };
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "key=${FirebaseCloudMessagingSecrets.serverKey}",
        },
        body: jsonEncode({
          'notification': {
            'title': notificationTitle,
            'body': notificationMessage,
          },
          'priority': notificationPriority,
          'data': data,
          'to': '/topics/$topic',
        }),
      );
      if (response.statusCode == 200) {
        Log.hint("SEND NOTIFICATION: Success!");
        return true;
      } else {
        Log.warning("SEND NOTIFICATION: Failed! (${response.statusCode})})");
        return false;
      }
    } catch (e) {
      Log.error("SEND NOTIFICATION: $e");
      return false;
    }
  }

  bool notificationSendByCurrentUser(RemoteMessage message) {
    final String sendByUserId = message.data['sendBy'] ?? "";
    final AppUser? currentUser = AppUser.current;
    if (currentUser?.id == sendByUserId) {
      Log.warning("Notification was send by current user. It will be ignored.");
      return true;
    }
    return false;
  }
}

// * Must be top-level (outside of any class)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  /// Initialize the Firebase app (needed to use other Firebase services)
  // await Firebase.initializeApp();
  Log.hint(
    "Received a background message with id=${message.messageId}."
    "\n\tdata: ${message.data}"
    "\n\tnotification: ${message.notification ?? "-"}",
  );
}

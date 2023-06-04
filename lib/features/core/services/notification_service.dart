import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log/log.dart';
import 'package:rating/constants/global.dart';

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
    String? token = await firebaseMessaging.getToken(
      // TODO: Move to secret file.
      vapidKey: "BBGSDgHDlYCJ2CefiP4yF07XBTspRV-jh_-kGX6Ld3lmG5YPn-IUeCEpcJKgK-Hep0_58TsOyNiRb50ESb6aYWk",
    );
    Log.hint("Registrated notification token: $token");
  }

  void _initForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Log.hint("Got a message whilst in the foreground! \n\tMessage data: ${message.data}");
      if (message.notification != null) {
        Log.hint("Message also contained a notification: \n\t${message.notification?.body}");
      }
      showDialog(
        context: Global.context,
        builder: (context) => AlertDialog(
          title: Text(message.notification?.title ?? ""),
          content: Text(message.notification?.body ?? ""),
          actions: [TextButton(onPressed: () => context.pop(), child: const Text("Okay"))],
        ),
      );
    });
  }

  void _initBackgroundNotifications() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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

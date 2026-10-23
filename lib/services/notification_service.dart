
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'Notification permission: ${settings.authorizationStatus}',
    );

    if (settings.authorizationStatus ==
            AuthorizationStatus.authorized ||
        settings.authorizationStatus ==
            AuthorizationStatus.provisional) {
      await _messaging.subscribeToTopic('aqi_alerts');

      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      debugPrint('FCM token: $token');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('AQI alert: ${message.notification?.title}');
      debugPrint('Message: ${message.notification?.body}');
    });
  }
}

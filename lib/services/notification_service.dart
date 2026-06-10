import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';

/// Handles Firebase push notification setup:
/// - Initializes Firebase
/// - Requests notification permission (iOS)
/// - Registers/refreshes the device's FCM token with the backend
/// - Listens for foreground/background messages
///
/// Safe to call even if `google-services.json` / `GoogleService-Info.plist`
/// haven't been added yet — Firebase.initializeApp() will throw and this
/// service simply no-ops, so the rest of the app keeps working.
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase not configured yet, skipping push notifications: $e');
      return;
    }

    try {
      // Ask the user for permission (iOS shows a system prompt; Android 13+ too).
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Register the current token with the backend.
      final token = await _messaging.getToken();
      if (token != null) {
        await _registerToken(token);
      }

      // Re-register whenever the token refreshes.
      _messaging.onTokenRefresh.listen(_registerToken);

      // Foreground messages are handled via FlutterLocalNotifications elsewhere
      // if needed; for now we just log them.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground push: ${message.notification?.title}');
      });

      // Tapped notification while app was in background.
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Push opened app: ${message.data}');
      });
    } catch (e) {
      debugPrint('Push notification setup failed: $e');
    }
  }

  static Future<void> _registerToken(String token) async {
    try {
      await ApiService.registerDeviceToken(
        token,
        platform: Platform.isIOS ? 'ios' : 'android',
      );
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }
}

/// Must be a top-level function. Handles messages received while the app is
/// terminated or in the background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background push: ${message.notification?.title}');
}

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zorvyn/services/api_service.dart';

/// Top-level handler for background FCM messages (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Nothing to do here — local notifications plugin handles display
}

class PushNotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channel = AndroidNotificationChannel(
    'zorvyn_high',
    'Zorvyn Notifications',
    description: 'Financial alerts, goals, budgets, and challenges',
    importance: Importance.high,
  );

  /// Call once after Firebase.initializeApp()
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Initialize local notifications plugin
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  /// Request notification permission on Android 13+ and iOS
  static Future<bool> requestPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        if (!status.isGranted) return false;
      }

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  /// Get current FCM token
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Register the FCM token with the backend
  static Future<void> registerDeviceToken(ApiService api) async {
    final token = await getToken();
    if (token == null) return;
    try {
      await api.post('/notifications/device-token', data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (_) {
      // Best-effort — backend may not be ready
    }
  }

  /// Listen for token refresh and re-register
  static void listenTokenRefresh(ApiService api) {
    _messaging.onTokenRefresh.listen((newToken) async {
      try {
        await api.post('/notifications/device-token', data: {
          'token': newToken,
          'platform': Platform.isIOS ? 'ios' : 'android',
        });
      } catch (_) {}
    });
  }

  /// Show a local notification when a message arrives in foreground
  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'Zorvyn',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

/// Provider to access push notification state
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});

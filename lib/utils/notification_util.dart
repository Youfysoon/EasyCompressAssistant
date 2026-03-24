import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// System notification utility
/// Sends different types of notifications based on platform
class NotificationUtil {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification plugin
  static Future<void> initialize() async {
    try {
      // Check if running on Android and notification permission is available
      if (Platform.isAndroid) {
        const initializationSettings = InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        );
        await _notifications.initialize(initializationSettings);
      } else if (Platform.isIOS) {
        const initializationSettings = InitializationSettings(
          iOS: DarwinInitializationSettings(),
        );
        await _notifications.initialize(initializationSettings);
      }
    } catch (e) {
      debugPrint('Notification plugin initialization error: $e');
      // Don't rethrow - notifications are not critical
    }
  }

  /// Send system notification
  static Future<void> sendNotification({
    required String title,
    required String content,
    String? payload,
  }) async {
    if (Platform.isAndroid) {
      await _sendAndroidNotification(title, content, payload);
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await _sendDesktopNotification(title, content, payload);
    } else if (Platform.isIOS) {
      await _sendIOSNotification(title, content, payload);
    }
  }

  /// Send Android notification
  static Future<void> _sendAndroidNotification(
      String title, String content, String? payload) async {
    const platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'easy_compress_channel',
        'Easy Compress Assistant',
        channelDescription: 'Notifications for Easy Compress Assistant',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      0,
      title,
      content,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Send desktop notification (Windows, Linux, macOS)
  static Future<void> _sendDesktopNotification(
      String title, String content, String? payload) async {
    const platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'easy_compress_desktop_channel',
        'Easy Compress Assistant Desktop',
        channelDescription: 'Desktop notifications for Easy Compress Assistant',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      0,
      title,
      content,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Send iOS notification
  static Future<void> _sendIOSNotification(
      String title, String content, String? payload) async {
    const platformChannelSpecifics = NotificationDetails(
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      0,
      title,
      content,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}

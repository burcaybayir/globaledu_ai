import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:globaledu_ai/core/utils/logger.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'globaledu_default';
  static const _channelName = 'GlobalEdu Notifications';
  static const _channelDesc = 'Default notification channel for GlobalEdu AI';

  static int _notificationId = 0;

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel (Android)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );
  }

  /// Shows a local notification.
  static Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      _notificationId++,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedules a notification.
  static Future<void> schedule({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Implementation depends on timezone package
    AppLogger.info('Scheduled notification: $title at $scheduledDate');
  }

  /// Cancels all notifications.
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static void _onNotificationTap(NotificationResponse response) {
    AppLogger.info('Local notification tapped: ${response.payload}');
    // TODO: Handle navigation based on payload
  }
}

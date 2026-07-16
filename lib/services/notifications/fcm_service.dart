import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:globaledu_ai/core/constants/firebase_constants.dart';
import 'package:globaledu_ai/core/utils/logger.dart';
import 'package:globaledu_ai/services/notifications/local_notification_service.dart';

/// Background message handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Background message received: ${message.messageId}');
}

class FcmService {
  FcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Set background handler
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    // Request permission (iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    AppLogger.info(
      'FCM permission status: ${settings.authorizationStatus}',
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _setupTokenRefresh();
      await _setupForegroundNotifications();
      await _subscribeToDefaultTopics();
    }
  }

  /// Gets the current FCM token.
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      AppLogger.error('Failed to get FCM token', e);
      return null;
    }
  }

  static Future<void> _setupTokenRefresh() async {
    // Get initial token
    final token = await getToken();
    if (token != null) {
      AppLogger.info('FCM Token: ${token.substring(0, 20)}...');
      // TODO: Save token to user profile in Firestore
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      AppLogger.info('FCM Token refreshed');
      // TODO: Update token in Firestore
    });
  }

  static Future<void> _setupForegroundNotifications() async {
    // Show notification banners in foreground (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Foreground message: ${message.notification?.title}');

      if (message.notification != null) {
        LocalNotificationService.show(
          title: message.notification!.title ?? 'GlobalEdu AI',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    });

    // Handle notification taps (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Notification tapped: ${message.data}');
      _handleNotificationTap(message.data);
    });
  }

  static Future<void> _subscribeToDefaultTopics() async {
    await _messaging.subscribeToTopic(FirebaseConstants.topicGeneral);
    await _messaging.subscribeToTopic(FirebaseConstants.topicDeadlines);
    AppLogger.info('Subscribed to default FCM topics');
  }

  /// Subscribe to a specific topic.
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic.
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Check if the app was opened from a terminated state via notification.
  static Future<void> checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }
  }

  static void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    // TODO: Navigate based on notification type
    AppLogger.info('Handle notification tap: type=$type, id=$id');
  }
}

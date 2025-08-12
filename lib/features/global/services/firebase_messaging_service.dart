import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ninjachiken/features/global/services/local_notifications_service.dart';

class FirebaseMessagingService {
  // Private constructor for singleton pattern
  FirebaseMessagingService._internal();

  // Singleton instance
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  // Factory constructor to provide singleton instance
  factory FirebaseMessagingService.instance() => _instance;

  // Reference to local notifications service for displaying notifications
  LocalNotificationsService? _localNotificationsService;
  bool _isInitialized = false;

  /// Initialize Firebase Messaging and sets up all message listeners
  Future<void> init({
    required LocalNotificationsService localNotificationsService,
  }) async {
    try {
      // Проверяем, что Firebase инициализирован
      if (!Firebase.apps.isNotEmpty) {
        print('Firebase not initialized, skipping FCM setup');
        return;
      }

      // Init local notifications service
      _localNotificationsService = localNotificationsService;

      // Handle FCM token
      await _handlePushNotificationsToken();

      // Request user permission for notifications
      await _requestPermission();

      // Register handler for background messages (app terminated)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Listen for messages when the app is in foreground
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Listen for notification taps when the app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      // Check for initial message that opened the app from terminated state
      try {
        final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage != null) {
          _onMessageOpenedApp(initialMessage);
        }
      } catch (e) {
        print('Error getting initial message: $e');
      }

      _isInitialized = true;
      print('Firebase Messaging Service initialized successfully');
    } catch (e) {
      print('Error initializing Firebase Messaging Service: $e');
    }
  }

  /// Retrieves and manages the FCM token for push notifications
  Future<void> _handlePushNotificationsToken() async {
    try {
      // Get the FCM token for the device
      final token = await FirebaseMessaging.instance.getToken();
      print('Push notifications token: $token');

      // Listen for token refresh events
      FirebaseMessaging.instance.onTokenRefresh
          .listen((fcmToken) {
            print('FCM token refreshed: $fcmToken');
            // TODO: optionally send token to your server for targeting this device
          })
          .onError((error) {
            // Handle errors during token refresh
            print('Error refreshing FCM token: $error');
          });
    } catch (e) {
      print('Error handling push notifications token: $e');
    }
  }

  /// Requests notification permission from the user
  Future<void> _requestPermission() async {
    try {
      // Request permission for alerts, badges, and sounds
      final result = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Log the user's permission decision
      print('User granted permission: ${result.authorizationStatus}');
    } catch (e) {
      print('Error requesting notification permission: $e');
    }
  }

  /// Handles messages received while the app is in the foreground
  void _onForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.data.toString()}');
    final notificationData = message.notification;
    if (notificationData != null) {
      // Display a local notification using the service
      _localNotificationsService?.showNotification(
        notificationData.title,
        notificationData.body,
        message.data.toString(),
      );
    }
  }

  /// Handles notification taps when app is opened from the background or terminated state
  void _onMessageOpenedApp(RemoteMessage message) {
    print('Notification caused the app to open: ${message.data.toString()}');
    // TODO: Add navigation or specific handling based on message data
  }

  /// Check if the service is properly initialized
  bool get isInitialized => _isInitialized;
}

/// Background message handler (must be top-level function or static)
/// Handles messages when the app is fully terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.data.toString()}');
}

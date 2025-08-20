import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  // Private constructor for singleton pattern
  LocalNotificationsService._internal();

  //Singleton instance
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();

  //Factory constructor to return singleton instance
  factory LocalNotificationsService.instance() => _instance;

  //Main plugin instance for handling notifications
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  //Android-specific initialization settings using app launcher icon
  final _androidInitializationSettings = const AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  //iOS-specific initialization settings with permission requests
  final _iosInitializationSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  //Windows-specific initialization settings
  final _windowsInitializationSettings = const WindowsInitializationSettings(
    appName: 'Ninja Chiken',
    appUserModelId: 'com.ninjachicken.eggroad',
    guid: '12345678-1234-1234-1234-123456789012',
  );

  //Linux-specific initialization settings
  final _linuxInitializationSettings = const LinuxInitializationSettings(
    defaultActionName: 'Open notification',
  );

  //macOS-specific initialization settings
  final _macosInitializationSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  //Android notification channel configuration
  final _androidChannel = const AndroidNotificationChannel(
    'channel_id',
    'Channel name',
    description: 'Android push notification channel',
    importance: Importance.max,
  );

  //Flag to track initialization status
  bool _isFlutterLocalNotificationInitialized = false;

  //Counter for generating unique notification IDs
  int _notificationIdCounter = 0;

  /// Initializes the local notifications plugin for Android, iOS, Windows, Linux and macOS.
  Future<void> init() async {
    // Check if already initialized to prevent redundant setup
    if (_isFlutterLocalNotificationInitialized) {
      return;
    }

    // Create plugin instance
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Combine platform-specific settings
    final initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings,
      windows: _windowsInitializationSettings,
      linux: _linuxInitializationSettings,
      macOS: _macosInitializationSettings,
    );

    // Initialize plugin with settings and callback for notification taps
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap in foreground
        print('Foreground notification has been tapped: ${response.payload}');
      },
    );

    // Create Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    // Mark initialization as complete
    _isFlutterLocalNotificationInitialized = true;
  }

  /// Show a local notification with the given title, body, and payload.
  Future<void> showNotification(
    String? title,
    String? body,
    String? payload,
  ) async {
    try {
      // Android-specific notification details
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.max,
        priority: Priority.high,
      );

      // iOS-specific notification details
      const iosDetails = DarwinNotificationDetails();

      // Windows-specific notification details
      const windowsDetails = WindowsNotificationDetails();

      // Linux-specific notification details
      const linuxDetails = LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.normal,
      );

      // macOS-specific notification details
      const macosDetails = DarwinNotificationDetails();

      // Combine platform-specific details
      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        windows: windowsDetails,
        linux: linuxDetails,
        macOS: macosDetails,
      );

      // Display the notification
      await _flutterLocalNotificationsPlugin.show(
        _notificationIdCounter++,
        title ?? 'Notification',
        body ?? '',
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}

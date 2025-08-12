import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:ninjachiken/features/menu_screen/view/menu_screen.dart';
import 'package:ninjachiken/features/splash_screen/data/repositories/tracking_repository.dart';
import 'package:ninjachiken/features/splash_screen/view/web_view_screen.dart';
import 'package:ninjachiken/features/global/services/firebase_messaging_service.dart';
import 'package:ninjachiken/features/global/services/local_notifications_service.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String trackerToken = "Fh6pP6";
  static const String trackerBaseUrl = "HTTPLINKHTTPLINK";

  final firebaseMessagingService = FirebaseMessagingService.instance();
  late final TrackingRepository _trackingRepository;

  @override
  void initState() {
    super.initState();

    _trackingRepository = TrackingRepository(
      supabaseEndpoint: "https://your-supabase-endpoint.com/track",
    );

    // Запускаем инициализацию после первого кадра, чтобы UI успел построиться
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialization();
    });
  }

  Future<void> _startInitialization() async {
    try {
      // Запускаем все операции параллельно
      final futures = <Future>[
        _initPushNotifications(),
        _handleTracking(),
        Future.delayed(const Duration(seconds: 2)), // Минимум 2 секунды
      ];

      // Ждем завершения всех операций
      await Future.wait(futures);
    } catch (e, st) {
      developer.log("Ошибка при инициализации: $e\n$st", name: 'SplashScreen');
      _goToMenu();
    }
  }

  /// Безопасная инициализация FCM
  Future<void> _initPushNotifications() async {
    try {
      // Проверяем, что Firebase доступен
      if (!Firebase.apps.isNotEmpty) {
        developer.log(
          'Firebase not available, skipping FCM initialization',
          name: 'SplashScreen',
        );
        return;
      }

      await firebaseMessagingService.init(
        localNotificationsService: LocalNotificationsService.instance(),
      );
    } catch (e) {
      developer.log("Ошибка инициализации FCM: $e", name: 'SplashScreen');
    }
  }

  /// Отправка данных трекинга
  Future<void> _handleTracking() async {
    final fullTrackerLink = "$trackerBaseUrl$trackerToken";
    developer.log(
      'Starting tracking process with link: $fullTrackerLink',
      name: 'SplashScreen',
    );

    bool isValid = false;
    try {
      isValid = await _trackingRepository.isTrackerLinkValid(fullTrackerLink);
      developer.log(
        'Tracker link validation result: $isValid',
        name: 'SplashScreen',
      );
    } catch (e) {
      developer.log('Ошибка проверки трекера: $e', name: 'SplashScreen');
    }

    if (!isValid) {
      developer.log(
        'Tracker link is invalid, going to menu',
        name: 'SplashScreen',
      );
      _goToMenu();
      return;
    }

    final trackingData = await _collectTrackingData();
    developer.log(
      'Collected tracking data: $trackingData',
      name: 'SplashScreen',
    );

    final filledLink = _buildTrackingUrl(fullTrackerLink, trackingData);
    developer.log('Built tracking URL: $filledLink', name: 'SplashScreen');

    try {
      final hasSent = await _trackingRepository.hasSentData();
      developer.log(
        'Has tracking data been sent before: $hasSent',
        name: 'SplashScreen',
      );

      if (!hasSent) {
        developer.log(
          'Sending tracking data for the first time',
          name: 'SplashScreen',
        );
        final success = await _trackingRepository.sendTrackingData(
          trackingData,
        );
        developer.log(
          'Tracking data send result: $success',
          name: 'SplashScreen',
        );

        if (success) {
          await _trackingRepository.markDataSent();
          developer.log(
            'Tracking data marked as sent in SharedPreferences',
            name: 'SplashScreen',
          );
        }
      } else {
        developer.log(
          'Tracking data already sent, skipping',
          name: 'SplashScreen',
        );
      }
    } catch (e) {
      developer.log('Ошибка отправки трекинга: $e', name: 'SplashScreen');
    }

    if (!mounted) return;
    developer.log(
      'Navigating to WebView with tracking URL',
      name: 'SplashScreen',
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => WebViewScreen(url: filledLink)),
    );
  }

  Future<Map<String, String>> _collectTrackingData() async {
    String installationId = "";
    String fcmToken = "";
    String appName = "";

    try {
      // Проверяем, что Firebase доступен перед вызовом методов
      if (Firebase.apps.isNotEmpty) {
        installationId = await FirebaseInstallations.instance.getId();
      }
    } catch (e) {
      developer.log(
        "Ошибка получения installationId: $e",
        name: 'SplashScreen',
      );
    }

    try {
      // Проверяем, что Firebase доступен перед вызовом методов
      if (Firebase.apps.isNotEmpty) {
        fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      }
    } catch (e) {
      developer.log("Ошибка получения FCM токена: $e", name: 'SplashScreen');
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appName = packageInfo.appName;
    } catch (e) {
      developer.log("Ошибка получения packageInfo: $e", name: 'SplashScreen');
    }

    return {
      "analyticsId": installationId,
      "notificationToken": fcmToken,
      "appName": appName,
      "trackerToken": trackerToken,
    };
  }

  String _buildTrackingUrl(String baseUrl, Map<String, String> params) {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        "aid": params["analyticsId"] ?? '',
        "cmid": params["notificationToken"] ?? '',
      },
    );
    return uri.toString();
  }

  void _goToMenu() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MenuScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/png/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Здесь можно добавить логотип или название приложения
              Text(
                'Ninja Chiken',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

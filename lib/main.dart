import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ninjachiken/features/global/services/firebase_messaging_service.dart';
import 'package:ninjachiken/features/global/services/local_notifications_service.dart';
import 'package:ninjachiken/features/settings_screen/bloc/setting_bloc.dart';
import 'package:ninjachiken/features/splash_screen/view/splash_screen.dart';
import 'package:ninjachiken/firebase_options.dart';
import 'package:ninjachiken/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // dotenv - загружаем только если файл существует
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: .env file not found, using default values');
  }

  try {
    // Инициализируем SharedPreferences перед Firebase
    await SharedPreferences.getInstance();

    // Инициализируем Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? 'https://your-default-supabase-url.supabase.co',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-default-anon-key',
    );
    print('Supabase initialized successfully');

    // Инициализируем уведомления
    final localNotificationsService = LocalNotificationsService.instance();
    await localNotificationsService.init();
    print('Local notifications service initialized');

    // Инициализируем Firebase Messaging
    try {
      final firebaseMessagingService = FirebaseMessagingService.instance();
      await firebaseMessagingService.init(
        localNotificationsService: localNotificationsService,
      );
      print('Firebase messaging service initialized');
    } catch (e) {
      print('Error initializing Firebase messaging service: $e');
      // Продолжаем работу приложения даже если FCM не инициализирован
    }
  } catch (e) {
    print('Error during app initialization: $e');
    // Продолжаем работу приложения даже если Firebase не инициализирован
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsBloc = SettingsBloc();
  }

  @override
  void dispose() {
    _settingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingsBloc,
      child: MaterialApp(theme: theme, home: const SplashScreen()),
    );
  }
}

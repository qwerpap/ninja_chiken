import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // App
  static String get appName => dotenv.env['APP_NAME'] ?? 'Breathe App';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '2.0.6';
  
  // API
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  
  // Проверка, загружены ли переменные
  static bool get isLoaded => dotenv.env.isNotEmpty;
  
  // Получение значения с дефолтным значением
  static String getValue(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }
}
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl {
    final envUrl = dotenv.env['SUPABASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    // Лучше выбросить ошибку, чем использовать неверный URL
    throw Exception('SUPABASE_URL not found in environment variables');
  }

  static String get supabaseAnonKey {
    final envKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    // Лучше выбросить ошибку, чем использовать неверный ключ
    throw Exception('SUPABASE_ANON_KEY not found in environment variables');
  }
}

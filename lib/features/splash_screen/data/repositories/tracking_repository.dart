import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackingRepository {
  static const String _sentKey = 'hasSentTrackingData'; //shared prefs

  TrackingRepository();

  //данные отправлятся только 1 раз
  Future<bool> hasSentData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sentKey) ?? false;
  }

  //данные отправлятся только 1 раз
  Future<void> markDataSent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sentKey, true);
  }

  Future<bool> isTrackerLinkValid(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      return false;
    }
  }

  //SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE
  //SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE
  Future<bool> sendTrackingData(Map<String, String> data) async {
    try {
      // Skip if notification token is not provided
      if (data['firebase_token'] == null) {
        return true;
      }

      final supabase = Supabase.instance.client;

      await supabase.from('clients').insert({
        'firebase_token': data['firebase_token'],
        'app_name': data['app_name'],
        'campaign': data['campaign'],
      });

      return true;
    } catch (e) {
      print('Ошибка отправки данных в Supabase: $e');
      return false;
    }
  }
}

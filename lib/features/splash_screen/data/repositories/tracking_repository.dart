import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TrackingRepository {
  static const String _sentKey = 'hasSentTrackingData'; //shared prefs
  final String supabaseEndpoint;

  TrackingRepository({required this.supabaseEndpoint});

  //данные отправлятся только 1 раз
  Future<bool> hasSentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSent = prefs.getBool(_sentKey) ?? false;
      developer.log('Tracking data already sent: $hasSent', name: 'TrackingRepository');
      return hasSent;
    } catch (e) {
      developer.log('Error checking if tracking data was sent: $e', name: 'TrackingRepository');
      return false;
    }
  }

  //данные отправлятся только 1 раз
  Future<void> markDataSent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_sentKey, true);
      developer.log('Tracking data marked as sent', name: 'TrackingRepository');
    } catch (e) {
      developer.log('Error marking tracking data as sent: $e', name: 'TrackingRepository');
    }
  }

  Future<bool> isTrackerLinkValid(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final isValid = response.statusCode >= 200 && response.statusCode < 400;
      developer.log('Tracker link validation: $url - Status: ${response.statusCode}, Valid: $isValid', name: 'TrackingRepository');
      return isValid;
    } catch (e) {
      developer.log('Error validating tracker link: $e', name: 'TrackingRepository');
      return false;
    }
  }

  //SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE
  //SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE//SUPABASE
  Future<bool> sendTrackingData(Map<String, String> data) async {
    try {
      developer.log('Sending tracking data to Supabase: $data', name: 'TrackingRepository');
      
      final response = await http.post(
        Uri.parse(supabaseEndpoint),
        headers: {
          "Content-Type": "application/json",
          "apikey": "YOUR_SUPABASE_API_KEY", 
          "Authorization": "Bearer YOUR_SUPABASE_API_KEY",
        },
        body: jsonEncode(data),
      );
      
      final success = response.statusCode >= 200 && response.statusCode < 300;
      developer.log('Supabase response: Status: ${response.statusCode}, Success: $success', name: 'TrackingRepository');
      
      return success;
    } catch (e) {
      developer.log('Error sending tracking data to Supabase: $e', name: 'TrackingRepository');
      return false;
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ninjachiken/features/records_screen/data/models/record_model.dart';

class RecordsService {
  Future<List<RecordModel>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('records') ?? [];
    return rawList
        .map((jsonString) => RecordModel.fromJson(jsonString))
        .toList();
  }

  Future<void> setRecords(List<RecordModel> records) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = records.map((r) => r.toJson()).toList();
    await prefs.setStringList('records', rawList);
  }

  Future<void> addRecord(RecordModel record) async {
    final records = await getRecords();
    records.add(record);
    await setRecords(records);
  }
}

import 'dart:convert';

class RecordModel {
  final String score;
  final String date;

  RecordModel({required this.score, required this.date});

  factory RecordModel.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return RecordModel(score: json['score'], date: json['date']);
  }

  String toJson() {
    final map = {'score': score, 'date': date};
    return jsonEncode(map);
  }
}

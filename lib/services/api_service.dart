import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/question.dart';

class ApiService {
  static const String baseUrl = 'http://10.178.180.190:8000/api';

  static Future<List<Question>> getQuestions(int lessonId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/lessons/$lessonId/questions'),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> data = jsonData['data'];

      return data.map((item) => Question.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load questions: ${response.statusCode}');
    }
  }
}

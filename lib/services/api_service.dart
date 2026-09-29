import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/question.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<void> createAccount({
    required String fullname,
    required String username,
    required String email,
    required int birthDay,
    required int birthMonth,
    required int birthYear,
    required String country,
    required String nativeLanguage,
    required String learningLanguage,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullname': fullname,
        'username': username,
        'email': email,
        'birth_day': birthDay,
        'birth_month': birthMonth,
        'birth_year': birthYear,
        'country': country,
        'native_language': nativeLanguage,
        'learning_language': learningLanguage,
        'password': password,
        'password_confirmation': password,
        'terms_accepted': true,
      }),
    );

    if (response.statusCode == 201) return;

    var message = 'Could not create account. Please try again.';
    try {
      final Object? responseBody = jsonDecode(response.body);
      if (responseBody is Map<String, dynamic>) {
        final errors = responseBody['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            message = firstError.first.toString();
          }
        } else if (responseBody['message'] is String) {
          message = responseBody['message'] as String;
        }
      }
    } on FormatException {
      message = 'Could not connect to the account service.';
    }

    throw Exception(message);
  }

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

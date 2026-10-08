import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/question.dart';
import '../models/vocabulary.dart';
import 'auth_session.dart';

class ApiService {
  static String get baseUrl {
    const override = String.fromEnvironment('API_URL');
    if (override.isNotEmpty) return override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

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

  static Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username_or_email': usernameOrEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      }
      throw const FormatException('Invalid login response.');
    }

    var message = 'Invalid username/email or password.';
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

  static Future<void> requestPasswordReset({
    required String usernameOrEmail,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username_or_email': usernameOrEmail}),
    );

    if (response.statusCode == 200) return;
    throw Exception(
      _responseError(
        response,
        'Could not request a reset code. Please try again.',
      ),
    );
  }

  static Future<void> resetPassword({
    required String usernameOrEmail,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username_or_email': usernameOrEmail,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 200) return;
    throw Exception(
      _responseError(
        response,
        'Could not change your password. Please try again.',
      ),
    );
  }

  static String _responseError(http.Response response, String fallback) {
    try {
      final Object? responseBody = jsonDecode(response.body);
      if (responseBody is Map<String, dynamic>) {
        final errors = responseBody['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
        if (responseBody['message'] is String) {
          return responseBody['message'] as String;
        }
      }
    } on FormatException {
      return 'Could not connect to the account service.';
    }

    return fallback;
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

  static Future<List<Vocabulary>> getVocabularies() async {
    final response = await http.get(Uri.parse('$baseUrl/vocabularies'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> data = jsonData['data'];

      return data.map((item) => Vocabulary.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load vocabularies: ${response.statusCode}');
    }
  }

  // Dikirim bersama token (kalau sudah login) supaya server bisa menandai
  // baris milik kita dan menyembunyikan user yang saling blokir.
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final token = AuthSession.instance.token;

    final response = await http
        .get(
          Uri.parse('$baseUrl/leaderboard'),
          headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> data = jsonData['data'];

      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    }

    throw Exception('Failed to load leaderboard: ${response.statusCode}');
  }
}

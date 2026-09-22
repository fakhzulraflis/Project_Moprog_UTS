import 'dart:convert';

import 'package:http/http.dart' as http;

class TranslationService {
  static Future<String> translate({
    required String text,
    required String targetLanguage,
  }) async {
    final url = Uri.parse(
      'https://api.mymemory.translated.net/get'
      '?q=${Uri.encodeComponent(text)}'
      '&langpair=id|$targetLanguage',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['responseData']['translatedText'];
    } else {
      throw Exception('Failed to translate text');
    }
  }
}
